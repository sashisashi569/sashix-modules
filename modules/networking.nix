# Network configuration
# - NetworkManager for connection management
# - MAC address randomization (privacy)
# - systemd-resolved: スタブリゾルバ (127.0.0.53) を常時有効化
#   DNS サーバの指定は各モジュールが上書き (AdGuard: 127.0.0.1 / デフォルト: NM が DHCP 提供)
#
# Tailscale VPN: see tailscale.nix
# Firewall: see firewall.nix
# Network protection (WARP + AdGuard): see network-protection.nix
{ lib, config, ... }:

let
  cfg = config.sashix.networking;
in

{
  options.sashix.networking = {
    enable = lib.mkEnableOption "networking";

    hostName = lib.mkOption {
      type        = lib.types.str;
      description = "System hostname";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.hostName = cfg.hostName;
    networking.networkmanager.enable = true;

    # NetworkManager の DNS クエリを systemd-resolved 経由に転送
    networking.networkmanager.dns = "systemd-resolved";

    # MAC address randomization (プライバシー保護): 接続のたびに新しいランダムMACを使用
    # 特定のSSIDのみstableにする場合 (MACが必要なAPなど):
    #   nmcli connection modify "<SSID>" wifi.cloned-mac-address stable
    networking.networkmanager.wifi.macAddress     = "random";
    networking.networkmanager.ethernet.macAddress = "random";

    # systemd-resolved: スタブリゾルバを常時有効化
    # 127.0.0.53 をローカル DNS スタブとして提供し、NM 経由の全クエリを受け付ける
    # DNS サーバ自体は adguard.nix (127.0.0.1) またはデフォルト (NM が DHCP で提供) が担当
    services.resolved = {
      enable = true;
      settings.Resolve.DNSStubListener = "yes";
    };
  };
}

# Network configuration
# - NetworkManager for connection management
# - Tailscale VPN service
# - MAC address randomization (privacy)
# - systemd-resolved DNS forwarding
#
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

    # Forward NetworkManager DNS config to systemd-resolved
    networking.networkmanager.dns = "systemd-resolved";

    # MAC address randomization (プライバシー保護): 接続のたびに新しいランダムMACを使用
    # 特定のSSIDのみstableにする場合 (MACが必要なAPなど):
    #   nmcli connection modify "<SSID>" wifi.cloned-mac-address stable
    networking.networkmanager.wifi.macAddress     = "random";
    networking.networkmanager.ethernet.macAddress = "random";

    # Tailscale VPN
    services.tailscale.enable = true;
  };
}

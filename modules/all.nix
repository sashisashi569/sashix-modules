# 全モジュール一括有効化
# sashix.all.enable = true で全モジュールを lib.mkDefault true にセット
# 個別に false で上書きして特定モジュールを除外できる
{ home-manager, lanzaboote }:
{ lib, config, ... }:

{
  imports = [
    (import ./home-manager.nix { inherit home-manager; })
    ./boot.nix
    (import ./secureboot.nix { inherit lanzaboote; })
    ./networking.nix
    ./tailscale.nix
    ./locale.nix
    ./audio.nix
    ./nix.nix
    ./yubikey.nix
    ./firewall.nix
    ./network-protection.nix  # warp.nix と adguard.nix を内包
    ./desktop.nix
    ./nvidia.nix
    ./virtualization.nix
    ./gnome
    ./hyprland
  ];

  options.sashix.all = {
    enable = lib.mkEnableOption "all sashix modules";
  };

  config = lib.mkIf config.sashix.all.enable {
    sashix = {
      boot.enable              = lib.mkDefault true;
      # secureboot は Secure Boot 不要なマシンで無効にする必要があるため false がデフォルト
      # Secure Boot を使うマシンは configuration.nix で明示的に有効化する
      secureboot.enable        = lib.mkDefault false;
      networking.enable        = lib.mkDefault true;
      tailscale.enable         = lib.mkDefault true;
      locale.enable            = lib.mkDefault true;
      audio.enable             = lib.mkDefault true;
      nix.enable               = lib.mkDefault true;
      yubikey.enable           = lib.mkDefault true;
      firewall.enable          = lib.mkDefault true;
      # warp と adguard は networkProtection に内包されるため個別設定不要
      # WARP は Tailscale exit-node と競合するため、明示的にオプトインする設計にする
      # (WARP が Connected 状態だと Tailscale の routing を上書きし、
      #  100.64.0.0/10 を含む Tailscale 通信が WARP トンネルに吸われる)
      networkProtection.enable = lib.mkDefault false;
      desktop.enable           = lib.mkDefault true;
      # nvidia はハードウェア依存のため false がデフォルト
      # NVIDIA GPU を搭載したマシンは configuration.nix で明示的に有効化する
      nvidia.enable            = lib.mkDefault false;
      virtualization.enable    = lib.mkDefault true;
      gnome.enable             = lib.mkDefault true;
      hyprland.enable          = lib.mkDefault true;
    };
  };
}

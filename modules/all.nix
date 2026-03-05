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
    ./locale.nix
    ./audio.nix
    ./nix.nix
    ./yubikey.nix
    ./firewall.nix
    ./network-protection.nix  # warp.nix と adguard.nix を内包
    ./desktop.nix
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
      locale.enable            = lib.mkDefault true;
      audio.enable             = lib.mkDefault true;
      nix.enable               = lib.mkDefault true;
      yubikey.enable           = lib.mkDefault true;
      firewall.enable          = lib.mkDefault true;
      # warp と adguard は networkProtection に内包されるため個別設定不要
      networkProtection.enable = lib.mkDefault true;
      desktop.enable           = lib.mkDefault true;
      virtualization.enable    = lib.mkDefault true;
      gnome.enable             = lib.mkDefault true;
      hyprland.enable          = lib.mkDefault true;
    };
  };
}

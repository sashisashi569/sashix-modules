# Secure Boot via lanzaboote + sbctl
# - boot.nix を imports に含む (secureboot.enable = true で boot も自動有効化)
# - lanzaboote: signs UKI images and installs them for Secure Boot
# - sbctl: manages Secure Boot keys stored in pkiBundle
#
# Initial setup (one-time, before first switch):
#   1. Enter UEFI Setup Mode (disable Secure Boot in firmware settings)
#   2. sudo sbctl create-keys  (keys stored in pkiBundle, default: /var/lib/sbctl)
#   3. sudo nixos-rebuild switch --flake .#<hostname>
#   4. sudo sbctl enroll-keys --microsoft
#   5. Re-enable Secure Boot in firmware settings
{ lanzaboote }:
{ lib, pkgs, config, ... }:

let
  cfg = config.sashix.secureboot;
in

{
  imports = [
    ./boot.nix
    lanzaboote.nixosModules.lanzaboote
  ];

  options.sashix.secureboot = {
    enable = lib.mkEnableOption "Secure Boot via lanzaboote";

    pkiBundle = lib.mkOption {
      type        = lib.types.str;
      default     = "/var/lib/sbctl";
      description = "Path to the sbctl PKI bundle (sbctl default: /var/lib/sbctl)";
    };
  };

  config = lib.mkIf cfg.enable {
    # secureboot を有効にすると boot も自動有効化
    sashix.boot.enable = lib.mkDefault true;

    # lanzaboote takes over the EFI install step; disable systemd-boot's own installer
    boot.loader.systemd-boot.enable = lib.mkForce false;

    boot.lanzaboote = {
      enable    = true;
      pkiBundle = cfg.pkiBundle;
    };

    environment.systemPackages = [ pkgs.sbctl ];
  };
}

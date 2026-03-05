# Boot configuration (Secure Boot 非依存部分)
# - Latest Linux kernel
# - systemd-based initrd (required for systemd-cryptenroll / TPM2 LUKS unlock)
# - Unified Kernel Image (UKI): kernel + initrd + cmdline bundled as single EFI binary
# - Keep last 3 generations in /boot
#
# Secure Boot (lanzaboote) は secureboot.nix を参照
{ lib, pkgs, config, ... }:

{
  options.sashix.boot = {
    enable = lib.mkEnableOption "boot configuration (kernel / initrd / UKI)";
  };

  config = lib.mkIf config.sashix.boot.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    # Enable systemd in initrd to allow systemd-cryptenroll for LUKS key enrollment
    boot.initrd.systemd.enable = true;

    # Generate bootspec JSON; combined with systemd initrd, produces UKI images
    # (kernel + initrd + cmdline → single PE/EFI binary via ukify)
    boot.bootspec.enable = true;

    boot.loader.efi.canTouchEfiVariables = true;

    # Keep only the last 3 generations in /boot (older UKI images are removed on switch)
    boot.loader.systemd-boot.configurationLimit = 3;
  };
}

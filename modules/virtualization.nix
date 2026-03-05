# Virtualization support
# - libvirtd: daemon for managing VMs (required by virt-manager)
# - virt-viewer: lightweight SPICE/VNC client for nixos-rebuild build-vm VMs
# - virt-manager: full GUI wrapper for VM lifecycle management
# - vmVariant: overrides host-specific config for nixos-rebuild build-vm
{ lib, pkgs, config, ... }:

let
  cfg = config.sashix.virtualization;
in

{
  options.sashix.virtualization = {
    enable = lib.mkEnableOption "virtualization via libvirtd";

    username = lib.mkOption {
      type        = lib.types.str;
      description = "Host user to add to the libvirtd group";
    };

    vmUsername = lib.mkOption {
      type        = lib.types.str;
      default     = "user";
      description = "Test user name for nixos-rebuild build-vm";
    };

    stateVersion = lib.mkOption {
      type        = lib.types.str;
      description = "home.stateVersion for the VM test user (should match system.stateVersion)";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.libvirtd.enable = true;

    users.users.${cfg.username}.extraGroups = [ "libvirtd" ];

    environment.systemPackages = with pkgs; [
      virt-viewer   # remote-viewer: connects to SPICE/VNC (build-vm default)
      virt-manager  # GUI for VM creation, management, and console access
    ];

    # VM-specific overrides for nixos-rebuild build-vm.
    # Prevents systemd from waiting for host-only devices
    # (LUKS UUID, EFI partition UUID, swap file, hibernation resume device).
    virtualisation.vmVariant = {
      # Secure Boot stack is not available in QEMU.
      # Use mkVMOverride (priority 10) to beat boot.nix's mkForce (priority 50).
      boot.lanzaboote.enable          = lib.mkVMOverride false;
      boot.loader.systemd-boot.enable = lib.mkVMOverride true;

      # systemd initrd is only needed for LUKS/TPM2 unlock; not needed in VM
      boot.initrd.systemd.enable = lib.mkVMOverride false;

      # No LUKS device in VM — prevents initrd from blocking on host UUID
      boot.initrd.luks.devices = lib.mkVMOverride {};

      # /boot (vfat, UUID 3E06-57AF) does not exist in VM.
      # Replace with tmpfs so systemd does not block waiting for the EFI partition.
      # / (LUKS mapper) is already handled by qemu-vm.nix via mkVMOverride.
      fileSystems."/boot" = lib.mkVMOverride {
        device  = "none";
        fsType  = "tmpfs";
        options = [ "mode=0755" ];
      };

      # Hibernation resume device (LUKS mapper) and swap file do not exist in VM
      boot.resumeDevice = lib.mkForce "";
      boot.kernelParams = lib.mkForce [];
      swapDevices       = lib.mkForce [];

      # Test user for VM (plain-text password via initialPassword; VM only)
      users.users.${cfg.vmUsername} = {
        isNormalUser    = true;
        initialPassword = cfg.vmUsername;
        extraGroups     = [ "wheel" ];
      };

      # Register user with home-manager so sharedModules (hyprland config etc.) are applied
      home-manager.users.${cfg.vmUsername} = {
        home.username      = cfg.vmUsername;
        home.homeDirectory = "/home/${cfg.vmUsername}";
        home.stateVersion  = cfg.stateVersion;
        programs.home-manager.enable = true;
      };
    };
  };
}

# Nix daemon configuration
# - Enable flakes and nix-command for all users
# - Automatic garbage collection (weekly, delete generations older than 30 days)
{ lib, config, ... }:

{
  options.sashix.nix = {
    enable = lib.mkEnableOption "Nix daemon configuration";
  };

  config = lib.mkIf config.sashix.nix.enable {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];

    # Automatically run garbage collection weekly to reclaim disk space.
    # Deletes system/user profile generations older than 30 days from the Nix store.
    # Boot-entry count is controlled separately by boot.loader.systemd-boot.configurationLimit.
    nix.gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };
  };
}

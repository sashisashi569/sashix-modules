# GNOME desktop environment — NixOS module
# - services.desktopManager.gnome.enable
# - gnome-extension-manager
# - Excluded GNOME packages: Maps, Tour, Help (Yelp), Web (Epiphany)
{ lib, pkgs, config, ... }:

{
  options.sashix.gnome = {
    enable = lib.mkEnableOption "GNOME desktop environment";
  };

  config = lib.mkIf config.sashix.gnome.enable {
    services.desktopManager.gnome.enable = true;

    environment.systemPackages = with pkgs; [
      gnome-extension-manager
    ];

    # Exclude unused GNOME packages
    environment.gnome.excludePackages = with pkgs; [
      gnome-maps
      gnome-tour
      yelp      # GNOME Help
      epiphany  # GNOME Web
    ];
  };
}

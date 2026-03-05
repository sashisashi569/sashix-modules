# home-manager: Adwaita cursor theme for Hyprland (Wayland + GTK + X11)
{ pkgs, ... }:

{
  home.pointerCursor = {
    name    = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size    = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  wayland.windowManager.hyprland.settings.env = [
    "XCURSOR_THEME,Adwaita"
    "XCURSOR_SIZE,24"
  ];
}

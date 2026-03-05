# home-manager: default terminal and file manager for Hyprland
{ ... }:

{
  home.sessionVariables = {
    TERMINAL     = "foot";
    FILE_MANAGER = "thunar";
  };

  xdg.mimeApps.defaultApplications = {
    "inode/directory" = [ "thunar.desktop" ];
  };
}

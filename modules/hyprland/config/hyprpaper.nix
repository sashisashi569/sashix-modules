# home-manager: services.hyprpaper
# Wallpaper paths (preload / wallpaper) are device-specific.
# Define them in home/<user>.nix using lib.mkForce.
{ ... }:

{
  services.hyprpaper = {
    enable   = true;
    settings = { };
  };
}

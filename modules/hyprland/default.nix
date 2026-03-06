# Hyprland desktop environment — NixOS module
# - programs.hyprland.enable and systemPackages (nixpkgs level)
# - home-manager.sharedModules: wires config/* as shared home-manager modules
#   スカラー値は config/* で定義済みのため、ローカルの home/<user>.nix で上書きする場合は lib.mkForce を使う
{ lib, pkgs, config, ... }:

{
  options.sashix.hyprland = {
    enable = lib.mkEnableOption "Hyprland desktop environment";
  };

  config = lib.mkIf config.sashix.hyprland.enable {
    programs.hyprland.enable = true;

    environment.systemPackages = with pkgs; [
      waybar
      hyprpaper
      hyprlock
      hypridle
      hyprdynamicmonitors
      rofi
      foot
      mako
      thunar
      grim
      slurp
      wl-clipboard
      brightnessctl
      networkmanagerapplet
      polkit_gnome
    ];

    home-manager.sharedModules = [
      ./config/defaults.nix
      ./config/hyprland.nix
      ./config/cursor.nix
      ./config/waybar.nix
      ./config/mako.nix
      ./config/foot.nix
      ./config/hyprlock.nix
      ./config/hypridle.nix
      ./config/hyprpaper.nix
      ./config/rofi.nix
      ./config/hyprdynamicmonitors.nix
    ];
  };
}

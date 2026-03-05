# home-manager: programs.rofi
{ pkgs, ... }:

{
  programs.rofi = {
    enable   = true;
    package  = pkgs.rofi;
    font     = "DejaVu Sans Mono 12";
    terminal = "foot";
    extraConfig = {
      modi       = "drun";
      show-icons = true;
    };
  };
}

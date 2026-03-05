# home-manager: programs.foot
{ ... }:

{
  programs.foot = {
    enable   = true;
    settings = {
      main.font = "DejaVu Sans Mono:size=12";
    };
  };
}

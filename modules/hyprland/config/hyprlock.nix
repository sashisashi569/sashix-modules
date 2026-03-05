# home-manager: programs.hyprlock
{ ... }:

{
  programs.hyprlock = {
    enable   = true;
    settings = {
      general = {
        grace       = 0;
        hide_cursor = true;
      };

      background = [{
        path        = "screenshot";
        blur_passes = 3;
        blur_size   = 8;
        brightness  = 0.8;
      }];

      label = [{
        text        = "$TIME";
        font_size   = 72;
        font_family = "DejaVu Sans";
        position    = "0, 120";
        halign      = "center";
        valign      = "center";
      }];

      "input-field" = [{
        size             = "200, 50";
        position         = "0, -80";
        halign           = "center";
        valign           = "center";
        dots_size        = 0.33;
        dots_spacing     = 0.15;
        fade_on_empty    = true;
        placeholder_text = "Password";
        rounding         = 8;
        fail_text        = "$FAIL ($ATTEMPTS)";
      }];
    };
  };
}

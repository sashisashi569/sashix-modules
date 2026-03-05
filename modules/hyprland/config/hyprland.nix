# home-manager: wayland.windowManager.hyprland
# Common compositor settings.
# Device-specific: monitor layout → home/<user>.nix (lib.mkForce)
{ pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable        = true;
    xwayland.enable = true;
    systemd.enable  = true;

    settings = {
      "$mod" = "SUPER";

      general = {
        gaps_in    = 1;
        gaps_out   = 0;
        border_size = 1;
        layout     = "dwindle";
      };

      decoration = {
        rounding       = 2;
        rounding_power = 1;
        blur.enabled   = true;
        shadow.enabled = false;
      };

      animations.enabled = true;

      input = {
        kb_layout    = "jp";
        repeat_rate  = 50;
        repeat_delay = 600;
        touchpad = {
          "tap-to-click" = true;
          natural_scroll = false;
        };
      };

      dwindle = {
        pseudotile    = true;
        preserve_split = true;
      };

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo   = true;
      };

      env = [
        "XMODIFIERS,@im=fcitx"
        "GTK_IM_MODULE,fcitx"
        "QT_IM_MODULE,fcitx"
        "SDL_IM_MODULE,fcitx"
        "NIXOS_OZONE_WL,1"
      ];

      "exec-once" = [
        "waybar"
        "hyprpaper"
        "mako"
        "fcitx5 --replace -d"
        "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
      ];

      bind = [
        # Applications
        "$mod, Q, exec, foot"
        "$mod, E, exec, thunar"
        "$mod, R, exec, rofi -show drun"
        "$mod, L, exec, hyprlock"
        "$mod CTRL, S, exec, grim -g \"$(slurp)\" ~/Pictures/screenshot-$(date +%Y%m%d-%H%M%S).png"
        # Window management
        "$mod, C, killactive"
        "$mod SHIFT, E, exit"
        "$mod, F, fullscreen"
        "$mod, V, togglefloating"
        # Focus
        "$mod, left,  movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up,    movefocus, u"
        "$mod, down,  movefocus, d"
        # Move window
        "$mod SHIFT, left,  movewindow, l"
        "$mod SHIFT, right, movewindow, r"
        "$mod SHIFT, up,    movewindow, u"
        "$mod SHIFT, down,  movewindow, d"
        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        # Special workspace (scratchpad)
        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"
      ];

      # Repeatable + active while locked
      bindel = [
        ", XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86MonBrightnessUp,   exec, brightnessctl set 10%+"
        ", XF86MonBrightnessDown, exec, brightnessctl set 10%-"
      ];

      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ];

      # Mouse binds
      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}

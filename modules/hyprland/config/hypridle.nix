# home-manager: services.hypridle
{ ... }:

{
  services.hypridle = {
    enable   = true;
    settings = {
      general = {
        lock_cmd         = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd  = "hyprctl dispatch dpms on";
      };

      listener = [
        {
          # Dim screen after 120 s of idle
          timeout    = 120;
          on-timeout = "brightnessctl -s set 10%";
          on-resume  = "brightnessctl -r";
        }
        {
          # Lock screen after 120 s of idle (simultaneous with dim)
          timeout    = 120;
          on-timeout = "loginctl lock-session";
        }
        {
          # Suspend after 30 min of idle
          timeout    = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };
}

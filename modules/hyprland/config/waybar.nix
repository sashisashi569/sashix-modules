# home-manager: programs.waybar
{ ... }:

{
  programs.waybar = {
    enable = true;

    settings = {
      mainBar = {
        layer    = "top";
        position = "top";
        height   = 24;
        width    = 0;

        modules-left   = [ "hyprland/workspaces" "hyprland/window" ];
        modules-center = [ "clock" ];
        modules-right  = [ "disk" "cpu" "memory" "network" "pulseaudio" "battery" "tray" ];

        "hyprland/workspaces" = { };

        "hyprland/window" = {
          max-length = 80;
        };

        clock = {
          format         = "{:%Y-%m-%d %a %H:%M}";
          tooltip-format = "<tt><small>{calendar}</small></tt>";
        };

        disk = {
          path   = "/";
          format = "Disk: {free}";
        };

        cpu = {
          format   = "CPU: {usage}%";
          interval = 5;
        };

        memory = {
          format   = "Mem: {used:.1f}G";
          interval = 5;
        };

        network = {
          format-wifi         = "WiFi: {essid} ({signalStrength}%)";
          format-ethernet     = "ETH: {ipaddr}";
          format-disconnected = "No network";
          tooltip-format      = "{ifname}: {ipaddr}";
        };

        pulseaudio = {
          format       = "Vol: {volume}%";
          format-muted = "Vol: muted";
          on-click     = "pavucontrol";
        };

        battery = {
          format          = "Bat: {capacity}% {time}";
          format-charging = "Bat: {capacity}% chr";
          format-full     = "Bat: full";
          format-time     = "{H}h{M}m";
          states = {
            warning  = 30;
            critical = 15;
          };
        };

        tray = {
          spacing = 10;
        };
      };
    };

    style = ''
      * {
        font-family: monospace;
        font-size: 13px;
        border: none;
        border-radius: 0;
        min-height: 0;
      }

      window#waybar {
        background-color: #1d1f21;
        color: #c5c8c6;
      }

      #workspaces button {
        padding: 0 6px;
        color: #969896;
        background: transparent;
      }

      #workspaces button.active {
        color: #c5c8c6;
        font-weight: bold;
      }

      #workspaces button.urgent {
        color: #cc6666;
      }

      #window {
        padding: 0 8px;
        color: #c5c8c6;
      }

      #clock {
        color: #c5c8c6;
        font-weight: bold;
      }

      #disk,
      #cpu,
      #memory,
      #network,
      #pulseaudio,
      #battery,
      #tray {
        padding: 0 8px;
        color: #c5c8c6;
        border-left: 1px solid #373b41;
      }

      #battery.warning {
        color: #f0c674;
      }

      #battery.critical {
        color: #cc6666;
      }

      #cpu.high {
        color: #f0c674;
      }
    '';
  };
}

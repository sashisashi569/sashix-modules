# home-manager: hyprdynamicmonitors
# Automatic monitor profile switching based on connected displays and lid state.
#
# First-time setup (after nixos-rebuild switch):
#   1. Arrange monitors as desired
#   2. hyprdynamicmonitors freeze --profile-name <name>
#   3. Repeat for each monitor combination
#   Config: ~/.config/hyprdynamicmonitors/config.toml
{ pkgs, lib, ... }:

{
  # Source the file hyprdynamicmonitors writes on profile switch.
  wayland.windowManager.hyprland.extraConfig = ''
    source = ~/.config/hypr/monitors.conf
  '';

  # Create an empty stub on first activation so Hyprland doesn't error
  # on a missing source file. hyprdynamicmonitors overwrites this at runtime.
  home.activation.initHyprMonitorConf = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -f "$HOME/.config/hypr/monitors.conf" ]; then
      run touch "$HOME/.config/hypr/monitors.conf"
    fi
  '';

  # Run as a systemd user service so it restarts on failure and starts
  # automatically with the graphical session.
  # HYPRLAND_INSTANCE_SIGNATURE is available because hyprland.systemd.enable = true
  # exports Hyprland env vars to the user session.
  systemd.user.services.hyprdynamicmonitors = {
    Unit = {
      Description = "HyprDynamicMonitors - automatic monitor profile switching";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.hyprdynamicmonitors}/bin/hyprdynamicmonitors run --enable-lid-events";
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}

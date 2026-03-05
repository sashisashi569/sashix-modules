# Firewall configuration
# - Default inbound policy: DROP (NixOS firewall drops uninvited inbound by default)
# - Tailscale interface (tailscale0) trusted
# - Tailscale UDP port allowed for direct peer connections
{ lib, config, ... }:

{
  options.sashix.firewall = {
    enable = lib.mkEnableOption "firewall configuration";
  };

  config = lib.mkIf config.sashix.firewall.enable {
    networking.firewall = {
      enable = true;

      # Trust Tailscale VPN interface (allows all traffic from tailscale0)
      trustedInterfaces = [ "tailscale0" ];

      # Allow Tailscale direct peer-to-peer connections (hole-punching)
      allowedUDPPorts = [ 41641 ];

      # Log refused connections (useful for debugging)
      logRefusedConnections = true;
    };
  };
}

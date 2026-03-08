# Firewall configuration
# - Default inbound policy: DROP (NixOS firewall drops uninvited inbound by default)
# - Tailscale interface (tailscale0) trusted
# - Tailscale UDP port allowed for direct peer connections
# - checkReversePath = "loose": Tailscale exit-node / Cloudflare WARP tunnel_only モードで
#   トンネル経由の折り返しパケット (送信元IP が外部IP) がドロップされるのを防ぐ
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

      # Tailscale exit-node / Cloudflare WARP (tunnel_only) 対応
      # トンネルインターフェース (tailscale0 / CloudflareWARP) 経由で届く折り返しパケットは
      # 送信元IPが外部IPになるため、strict だとスプーフィングと誤検知されドロップされる
      checkReversePath = "loose";
    };
  };
}

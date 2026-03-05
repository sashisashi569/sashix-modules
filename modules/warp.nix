# Cloudflare WARP: tunnel_only mode (TCP/UDP全通信を暗号化、DNS制御は行わない)
# Split-tunnel exclusions (デフォルトで既に含まれている):
#   Tailnet:  100.64.0.0/10 (MagicDNS 100.100.100.100 を含む)
#             fc00::/7     (fd7a:115c:a1e0::/48 を含む)
#   LAN:      10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16
#             (DHCP提供のプライベートサブネットをすべてカバー)
# First-time setup:
#   warp-cli --accept-tos registration new
#   warp-cli --accept-tos connect
#   (tunnel_only モードは cloudflare-warp-configure.service が自動設定)
# 登録後に手動設定が必要な場合:
#   sudo systemctl restart cloudflare-warp-configure
{ lib, pkgs, config, ... }:

{
  options.sashix.warp = {
    enable = lib.mkEnableOption "Cloudflare WARP tunnel_only mode";
  };

  config = lib.mkIf config.sashix.warp.enable {
    services.cloudflare-warp.enable = true;

    # tunnel_only モードを強制設定するサービス
    # WARP未登録の場合はスキップ (登録後に restart して適用)
    systemd.services.cloudflare-warp-configure = {
      description = "Configure Cloudflare WARP to tunnel_only mode";
      after       = [ "warp-svc.service" ];
      wants       = [ "warp-svc.service" ];
      wantedBy    = [ "multi-user.target" ];
      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
      };
      script = ''
        ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos mode tunnel_only || true
      '';
    };
  };
}

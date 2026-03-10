# Cloudflare WARP モジュール
#
# --- tunnel_only モード (デフォルト) ---
#   TCP/UDP 全通信を暗号化トンネル経由にする。DNS 制御は行わない。
#   Split-tunnel exclusions (cloudflare-warp-configure.service で明示設定):
#     Tailnet:  100.64.0.0/10 (MagicDNS 100.100.100.100 を含む)
#               fc00::/7     (fd7a:115c:a1e0::/48 を含む)
#     LAN:      10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16 (WARP デフォルト)
#
# --- proxy モード ---
#   全通信をトンネリングせず、ローカル SOCKS5/HTTPS プロキシを提供する。
#   アプリ単位で WARP 経由にしたいユーザー向け。
#   デフォルトポート: 40000 (SOCKS5) / 40001 (HTTPS proxy)
#   接続先: 127.0.0.1:<port>
#
# First-time setup:
#   warp-cli --accept-tos registration new
#   warp-cli --accept-tos connect
#   (モードは cloudflare-warp-configure.service が自動設定)
# 登録後に手動設定が必要な場合:
#   sudo systemctl restart cloudflare-warp-configure
{ lib, pkgs, config, ... }:

let
  cfg = config.sashix.warp;
in
{
  options.sashix.warp = {
    enable = lib.mkEnableOption "Cloudflare WARP";

    proxy = {
      enable = lib.mkEnableOption "proxy mode (全通信トンネリングの代わりにローカル SOCKS5 プロキシを使用)";

      port = lib.mkOption {
        type        = lib.types.port;
        default     = 40000;
        description = "WARP proxy が listen する SOCKS5 ポート番号";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.cloudflare-warp.enable = true;

    # WARP トンネルインターフェースをファイアウォールで信頼する
    # tunnel_only モードでは CloudflareWARP インターフェース経由でトラフィックが流れるため、
    # trustedInterfaces に追加しないとパケットが INPUT ルールでドロップされる
    networking.firewall.trustedInterfaces = [ "CloudflareWARP" ];

    # モードを設定するサービス
    # WARP 未登録の場合はスキップ (登録後に restart して適用)
    systemd.services.cloudflare-warp-configure = {
      description = "Configure Cloudflare WARP mode";
      after       = [ "warp-svc.service" ];
      wants       = [ "warp-svc.service" ];
      wantedBy    = [ "multi-user.target" ];
      serviceConfig = {
        Type            = "oneshot";
        RemainAfterExit = true;
      };
      script =
        if cfg.proxy.enable then ''
          ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos mode proxy || true
          ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos proxy port ${toString cfg.proxy.port} || true
        ''
        else ''
          ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos mode tunnel_only || true
        '' + ''
          # Tailscale 帯域を WARP トンネルから除外 (split-tunnel)
          # これを設定しないと WARP が 100.64.0.0/10 を含む Tailscale 通信を
          # WARP トンネルに吸い込み、exit-node / MagicDNS (100.100.100.100) が壊れる
          ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos tunnel exclude add 100.64.0.0/10 || true
          ${pkgs.cloudflare-warp}/bin/warp-cli --accept-tos tunnel exclude add fc00::/7      || true
        '';
    };
  };
}

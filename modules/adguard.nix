# AdGuard Home: ローカルDNSサーバ + systemd-resolved スタブリゾルバ
# Web UI: http://localhost:3000
#
# 上流DNS (sashix.warp.enable の有無で自動切替):
#   WARP あり: 1.1.1.1 / 1.0.0.1 (plain DNS) — WARP が既にトランスポートを暗号化するため DoH 不要
#              検証済み: 1.1.1.1 は CloudflareWARP 経由でルーティングされる (ip route get 1.1.1.1)
#              DoH はこの構成では二重暗号化になりオーバーヘッドのみ増大するため無効
#   WARP なし: 9.9.9.9 / 149.112.112.112 (Quad9, plain DNS)
#
# systemd-resolved:
#   グローバル: AdGuard Home (127.0.0.1) — フィルタリング + DNS解決
#   tailnet:   Tailscale MagicDNS (100.100.100.100) — per-link で自動設定 (tailscaled)
#   fallback:  9.9.9.9 / 149.112.112.112 (Quad9) — AdGuard 障害時の最終手段
#              ※ LAN DNS は公衆無線でのポイズニングリスクのため使用しない
{ lib, config, ... }:

let
  cfg         = config.sashix.adguard;
  warpEnabled = config.services.cloudflare-warp.enable;
in

{
  options.sashix.adguard = {
    enable = lib.mkEnableOption "AdGuard Home local DNS server";
  };

  config = lib.mkIf cfg.enable {
    # AdGuard Home: ローカルDNSサーバ (127.0.0.1:53)
    services.adguardhome = {
      enable          = true;
      host            = "127.0.0.1";
      port            = 3000;
      mutableSettings = true;  # Web UIでの設定変更をビルド間で保持する
      settings = {
        dns = {
          bind_hosts = [ "127.0.0.1" ];
          port       = 53;
          # WARP あり: Cloudflare DNS (WARP が暗号化、二重暗号化を避けるため plain)
          # WARP なし: Quad9 (プライバシー重視, plain)
          upstream_dns = if warpEnabled
            then [ "1.1.1.1" "1.0.0.1" ]
            else [ "9.9.9.9" "149.112.112.112" ];
          fallback_dns = [
            "9.9.9.9"
            "149.112.112.112"
          ];
          enable_dnssec = true;
        };
      };
    };

    # systemd-resolved: スタブリゾルバ (127.0.0.53)
    # グローバル DNS: AdGuard Home のみ (Tailscale MagicDNS は tailscaled が per-link で自動設定)
    #   100.100.100.100 をグローバルに入れると tailnet 外クエリが全て SERVFAIL になりノイズが増大
    # FallbackDNS: AdGuard が応答不能の場合の最終手段
    #   LAN DNS (DHCP提供) は公衆無線でのポイズニングリスクがあるため使用しない
    services.resolved = {
      enable = true;
      settings.Resolve = {
        DNS            = "127.0.0.1";
        FallbackDNS    = "9.9.9.9 149.112.112.112";
        DNSSEC         = "allow-downgrade";
        DNSStubListener = "yes";
      };
    };
  };
}

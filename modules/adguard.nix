# AdGuard Home: ローカルDNSサーバ + systemd-resolved スタブリゾルバ
# Web UI: http://localhost:3000
#
# 上流DNS (各オプションの組み合わせで自動切替):
#   dohViaWarpProxy あり: DoH (HTTPS/TCP) を WARP SOCKS5 プロキシ経由で送出
#                         upstream: https://1.1.1.1/dns-query, https://9.9.9.9/dns-query (IP直指定でbootstrap不要)
#                         proxy:    socks5://127.0.0.1:<warp.proxy.port>
#                         効果: DNS クエリが WARP 暗号化トンネル + DoH の二重保護を受ける
#   WARP あり (proxy無し): 1.1.1.1 / 1.0.0.1 (plain DNS)
#     ※ tunnel_only モードでは全 TCP/UDP が WARP の暗号化トンネルを通るため、
#        DNS クエリも例外なく保護される。この状態で DoH を重ねても ISP への
#        秘匿性は向上せず、TLS ハンドシェイクのオーバーヘッドが増えるだけ。
#        DoH が有効に機能するのは通信が保護されていない経路 (平文 UDP) に
#        限られる。WARP proxy モード + dohViaWarpProxy を使うこと。
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
  warpCfg     = config.sashix.warp;
  useDoHProxy = cfg.dohViaWarpProxy.enable;
in

{
  options.sashix.adguard = {
    enable = lib.mkEnableOption "AdGuard Home local DNS server";

    dohViaWarpProxy = {
      enable = lib.mkEnableOption ''
        DNS-over-HTTPS (TCP) を WARP proxy モード経由で送出する厳格秘匿化モード。
        sashix.warp.proxy.enable = true が必要。
        有効にすると upstream DNS が DoH (HTTPS) になり、すべてのクエリが
        WARP SOCKS5 プロキシ経由でトンネリングされる
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !useDoHProxy || (warpEnabled && warpCfg.proxy.enable);
        message   = "sashix.adguard.dohViaWarpProxy.enable には sashix.warp.proxy.enable = true が必要です。"
                  + " tunnel_only モードでは全通信が既に WARP トンネルで保護されるため DoH を重ねる意味はなく、"
                  + " proxy モードでのみ DoH による DNS 秘匿化が有効です。";
      }
    ];

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

          upstream_dns =
            if useDoHProxy then [
              # IP アドレス直指定で bootstrap DNS 解決を不要にする
              "https://1.1.1.1/dns-query"
              "https://1.0.0.1/dns-query"
            ]
            else if warpEnabled then [
              # WARP が既にトランスポートを暗号化するため plain DNS で十分
              "1.1.1.1"
              "1.0.0.1"
            ]
            else [
              "9.9.9.9"
              "149.112.112.112"
            ];

          fallback_dns =
            if warpEnabled then [
              "1.1.1.1"
              "1.0.0.1"
            ]
            else [
              "9.9.9.9"
              "149.112.112.112"
            ];

          # DoH over WARP proxy: すべての upstream クエリを SOCKS5 経由で送出
          proxy = lib.mkIf useDoHProxy
            "socks5://127.0.0.1:${toString warpCfg.proxy.port}";

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
        FallbackDNS    = if warpEnabled then "1.1.1.1 1.0.0.1" else "9.9.9.9 149.112.112.112";
        DNSSEC         = "allow-downgrade";
        DNSStubListener = "yes";
      };
    };
  };
}

# Tailscale VPN
# このモジュールを有効化することで Tailscale が導入されます。
# 利用規約およびプライバシーポリシーを確認してください:
#   Terms:   https://tailscale.com/terms
#   Privacy: https://tailscale.com/privacy-policy
{ lib, config, ... }:

{
  options.sashix.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";
  };

  config = lib.mkIf config.sashix.tailscale.enable {
    services.tailscale.enable = true;

    # exit-node クライアントとして使用するための設定
    # checkReversePath = "loose" を有効にし、exit-node 経由の折り返しパケットを受け入れる
    # "server" または "both" に上書きすれば exit-node のアドバタイズも可能
    services.tailscale.useRoutingFeatures = lib.mkDefault "client";
  };
}

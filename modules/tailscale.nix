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
  };
}

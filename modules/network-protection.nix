# Network protection bundle: AdGuard のみ
# warp.nix を使う場合は直接 import してください
# 個別に使う場合は adguard.nix を直接 import してください
{ lib, config, ... }:

{
  imports = [
    ./adguard.nix
  ];

  options.sashix.networkProtection = {
    enable = lib.mkEnableOption "network protection (AdGuard)";
  };

  config = lib.mkIf config.sashix.networkProtection.enable {
    sashix.adguard.enable = lib.mkDefault true;
  };
}

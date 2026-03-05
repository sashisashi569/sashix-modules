# Network protection bundle: WARP + AdGuard
# 個別に使う場合は warp.nix / adguard.nix を直接 import してください
{ lib, config, ... }:

{
  imports = [
    ./warp.nix
    ./adguard.nix
  ];

  options.sashix.networkProtection = {
    enable = lib.mkEnableOption "network protection (WARP + AdGuard)";
  };

  config = lib.mkIf config.sashix.networkProtection.enable {
    sashix.warp.enable   = lib.mkDefault true;
    sashix.adguard.enable = lib.mkDefault true;
  };
}

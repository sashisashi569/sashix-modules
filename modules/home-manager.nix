# home-manager: home-manager NixOS モジュール有効化 + useGlobalPkgs / useUserPackages 共通設定
{ home-manager }:
{ lib, ... }:

{
  imports = [ home-manager.nixosModules.home-manager ];

  home-manager.useGlobalPkgs   = lib.mkDefault true;
  home-manager.useUserPackages = lib.mkDefault true;
}

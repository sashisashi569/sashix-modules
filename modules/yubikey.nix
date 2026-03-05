# YubiKey support
# - pcscd: smart card daemon (required for CCID interface)
# - GPG agent with SSH support
# - yubikey-manager: CLI management tool
# - yubioath-flutter: OATH/TOTP authenticator GUI
# - yubikey-personalization: CLI personalization tool
{ lib, pkgs, config, ... }:

{
  options.sashix.yubikey = {
    enable = lib.mkEnableOption "YubiKey support";
  };

  config = lib.mkIf config.sashix.yubikey.enable {
    services.pcscd.enable = true;

    programs.gnupg.agent = {
      enable           = true;
      enableSSHSupport = true;
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubikey-personalization
      yubioath-flutter
    ];
  };
}

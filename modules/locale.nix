# Locale and timezone configuration
# - Timezone: Asia/Tokyo
# - Locale: ja_JP.UTF-8 (Japanese)
# - Input Method: fcitx5 with mozc for Japanese IME
{ lib, pkgs, config, ... }:

{
  options.sashix.locale = {
    enable = lib.mkEnableOption "locale and timezone configuration";
  };

  config = lib.mkIf config.sashix.locale.enable {
    time.timeZone = "Asia/Tokyo";

    # Virtual console (TTY) keyboard layout
    console.keyMap = "jp106";

    i18n.defaultLocale = "ja_JP.UTF-8";

    i18n.extraLocaleSettings = {
      LC_ADDRESS        = "ja_JP.UTF-8";
      LC_IDENTIFICATION = "ja_JP.UTF-8";
      LC_MEASUREMENT    = "ja_JP.UTF-8";
      LC_MONETARY       = "ja_JP.UTF-8";
      LC_NAME           = "ja_JP.UTF-8";
      LC_NUMERIC        = "ja_JP.UTF-8";
      LC_PAPER          = "ja_JP.UTF-8";
      LC_TELEPHONE      = "ja_JP.UTF-8";
      LC_TIME           = "ja_JP.UTF-8";
    };

    # Japanese Input Method (fcitx5 with mozc)
    i18n.inputMethod = {
      type   = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };
}

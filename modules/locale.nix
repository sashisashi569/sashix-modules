# Locale and timezone configuration
{ lib, pkgs, config, ... }:

let
  cfg = config.sashix.locale;
in
{
  options.sashix.locale = {
    enable = lib.mkEnableOption "locale and timezone configuration";

    timeZone = lib.mkOption {
      type    = lib.types.str;
      default = "UTC";
      description = "System timezone (e.g. \"Asia/Tokyo\", \"UTC\").";
    };

    keyMap = lib.mkOption {
      type    = lib.types.str;
      default = "us";
      description = "Virtual console (TTY) keyboard layout (e.g. \"jp106\", \"us\").";
    };

    defaultLocale = lib.mkOption {
      type    = lib.types.str;
      default = "C.UTF-8";
      description = "System default locale (e.g. \"C.UTF-8\", \"ja_JP.UTF-8\").";
    };

    japaneseInput = lib.mkOption {
      type    = lib.types.bool;
      default = false;
      description = "Enable Japanese input method (fcitx5 with mozc).";
    };
  };

  config = lib.mkIf cfg.enable {
    time.timeZone = cfg.timeZone;

    console.keyMap = cfg.keyMap;

    i18n.defaultLocale = cfg.defaultLocale;

    i18n.extraLocaleSettings = lib.mkIf (cfg.defaultLocale != "C.UTF-8") {
      LC_ADDRESS        = cfg.defaultLocale;
      LC_IDENTIFICATION = cfg.defaultLocale;
      LC_MEASUREMENT    = cfg.defaultLocale;
      LC_MONETARY       = cfg.defaultLocale;
      LC_NAME           = cfg.defaultLocale;
      LC_NUMERIC        = cfg.defaultLocale;
      LC_PAPER          = cfg.defaultLocale;
      LC_TELEPHONE      = cfg.defaultLocale;
      LC_TIME           = cfg.defaultLocale;
    };

    i18n.inputMethod = lib.mkIf cfg.japaneseInput {
      type   = "fcitx5";
      enable = true;
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };
  };
}

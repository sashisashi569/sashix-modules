# Desktop base configuration
# - X server + GDM display manager
# - CUPS printing service
# - Fonts (Noto CJK, Liberation, DejaVu)
# - Default browser / editor via env vars and XDG MIME (オプションで変更可)
# - Common desktop services: keyring, upower, avahi, bluetooth, bolt,
#   power-profiles-daemon, gvfs, udisks2, fwupd, tumbler, thermald,
#   colord, dconf, xdg.mime/icons, gnupg, flatpak
# - Redistributable firmware
{ lib, pkgs, config, ... }:

let
  cfg = config.sashix.desktop;
in

{
  options.sashix.desktop = {
    enable = lib.mkEnableOption "desktop environment base";

    browser = lib.mkOption {
      type        = lib.types.str;
      default     = "floorp";
      description = "Default browser command name (used in env vars and XDG MIME .desktop file)";
    };

    browserPackage = lib.mkOption {
      type        = lib.types.package;
      default     = pkgs.brave;
      description = "Default browser package";
    };

    editor = lib.mkOption {
      type        = lib.types.str;
      default     = "vim";
      description = "Default editor command name (EDITOR / VISUAL env vars)";
    };

    xkbLayout = lib.mkOption {
      type        = lib.types.str;
      default     = "us";
      description = "X11 keyboard layout (e.g. \"us\", \"jp\").";
    };

    xkbVariant = lib.mkOption {
      type        = lib.types.str;
      default     = "";
      description = "X11 keyboard variant.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver.enable         = true;
    services.displayManager.gdm.enable = true;

    # Keyboard layout
    services.xserver.xkb = {
      layout  = cfg.xkbLayout;
      variant = cfg.xkbVariant;
    };

    # Printing
    services.printing.enable = true;

    # Keyring (PAM integration included)
    services.gnome.gnome-keyring.enable = true;
    programs.seahorse.enable = true;

    # Power management
    services.upower.enable                = true;
    services.power-profiles-daemon.enable = true;

    # Network discovery (mDNS / DNS-SD)
    services.avahi = {
      enable   = true;
      nssmdns4 = true;
    };

    # Thunderbolt device security
    services.hardware.bolt.enable = true;

    # Bluetooth
    hardware.bluetooth.enable = true;

    # Virtual filesystem (all backends)
    services.gvfs.enable = true;

    # Removable media management (required by gvfs)
    services.udisks2.enable = true;

    # Thumbnail generation (for Thunar)
    services.tumbler.enable = true;

    # Firmware updates (BIOS, SSD, Thunderbolt, etc.)
    services.fwupd.enable = true;

    # Redistributable firmware (WiFi, GPU, etc.)
    hardware.enableRedistributableFirmware = true;

    # Thermal management (Intel CPU)
    services.thermald.enable = true;

    # Color management
    services.colord.enable = true;

    # GSettings database (required by GTK apps)
    programs.dconf.enable = true;

    # System MIME database and icon themes
    xdg.mime.enable  = true;
    xdg.icons.enable = true;

    # GPG agent
    programs.gnupg.agent.enable = true;

    # Flatpak
    services.flatpak.enable = true;

    # Fonts
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        liberation_ttf
        dejavu_fonts
      ];

      fontconfig = {
        enable = true;
        defaultFonts = {
          serif     = [ "Noto Serif" "Noto Serif CJK JP" ];
          sansSerif = [ "Noto Sans" "Noto Sans CJK JP" ];
          monospace = [ "DejaVu Sans Mono" ];
        };
      };
    };

    # Browser and email client
    environment.systemPackages = [
      cfg.browserPackage
      pkgs.thunderbird
    ];

    # Default applications — browser, email, editor (applied to all users)
    home-manager.sharedModules = [
      {
        home.sessionVariables = {
          BROWSER        = cfg.browser;
          EDITOR         = cfg.editor;
          VISUAL         = cfg.editor;
          NIXOS_OZONE_WL = "1";
        };

        xdg.mimeApps = {
          enable = true;
          defaultApplications = {
            "text/html"                = [ "${cfg.browser}.desktop" ];
            "x-scheme-handler/http"    = [ "${cfg.browser}.desktop" ];
            "x-scheme-handler/https"   = [ "${cfg.browser}.desktop" ];
            "x-scheme-handler/about"   = [ "${cfg.browser}.desktop" ];
            "x-scheme-handler/unknown" = [ "${cfg.browser}.desktop" ];
            "x-scheme-handler/mailto"  = [ "thunderbird.desktop" ];
            "message/rfc822"           = [ "thunderbird.desktop" ];
          };
        };
      }
    ];
  };
}

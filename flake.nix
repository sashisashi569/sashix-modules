{
  description = "sashisashi の再利用可能な NixOS モジュール集";

  inputs = {
    nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
    lanzaboote     = { url = "github:nix-community/lanzaboote";   inputs.nixpkgs.follows = "nixpkgs"; };
    home-manager   = { url = "github:nix-community/home-manager"; inputs.nixpkgs.follows = "nixpkgs"; };
  };

  outputs = { self, nixpkgs, lanzaboote, home-manager }: {
    nixosModules.modules = {
      all               = import ./modules/all.nix { inherit home-manager lanzaboote; };
      home-manager      = import ./modules/home-manager.nix { inherit home-manager; };
      boot              = import ./modules/boot.nix;
      secureboot        = import ./modules/secureboot.nix { inherit lanzaboote; };
      networking        = import ./modules/networking.nix;
      locale            = import ./modules/locale.nix;
      audio             = import ./modules/audio.nix;
      nix               = import ./modules/nix.nix;
      yubikey           = import ./modules/yubikey.nix;
      firewall          = import ./modules/firewall.nix;
      warp              = import ./modules/warp.nix;
      adguard           = import ./modules/adguard.nix;
      networkProtection = import ./modules/network-protection.nix;
      desktop           = import ./modules/desktop.nix;
      virtualization    = import ./modules/virtualization.nix;
      gnome             = import ./modules/gnome;
      hyprland          = import ./modules/hyprland;
      lanzaboote        = lanzaboote.nixosModules.lanzaboote;
    };
  };
}

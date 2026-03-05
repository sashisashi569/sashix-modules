# sashix-modules

sashisashi が管理する再利用可能な NixOS モジュール集。

## リポジトリの目的

- マシン固有でない NixOS 設定を汎用モジュールとして切り出す
- 各モジュールは `sashix.<name>.enable` オプションで有効/無効を切り替える
- `sashix.all.enable = true` で全モジュールを一括有効化できる

## ディレクトリ構造

```
flake.nix
modules/
├── all.nix                   # 全モジュール一括有効化
├── home-manager.nix          # home-manager 有効化 + useGlobalPkgs / useUserPackages 共通設定
├── boot.nix                  # カーネル・initrd・UKI (Secure Boot 非依存部分)
├── secureboot.nix            # lanzaboote + sbctl (Secure Boot 依存部分)
├── networking.nix
├── locale.nix
├── audio.nix
├── nix.nix
├── yubikey.nix
├── firewall.nix
├── warp.nix
├── adguard.nix
├── network-protection.nix
├── desktop.nix
├── virtualization.nix
├── gnome/
│   └── default.nix
└── hyprland/
    ├── default.nix
    └── config/
        ├── defaults.nix
        ├── hyprland.nix
        ├── cursor.nix
        ├── waybar.nix
        ├── mako.nix
        ├── foot.nix
        ├── hyprlock.nix
        ├── hypridle.nix
        ├── hyprpaper.nix
        └── rofi.nix
```

## flake.nix の構造

inputs として以下を管理し、ローカルリポジトリ側は `follows` で参照するため
このリポジトリが nixpkgs の唯一の参照元となる。

```nix
inputs = {
  nixpkgs.url    = "github:NixOS/nixpkgs/nixos-unstable";
  lanzaboote     = { url = "github:nix-community/lanzaboote";        inputs.nixpkgs.follows = "nixpkgs"; };
  home-manager   = { url = "github:nix-community/home-manager";      inputs.nixpkgs.follows = "nixpkgs"; };
};
```

outputs のキー構造はディレクトリ構造を継承する:

```nix
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
```

## モジュール設計の規則

### オプション命名

すべてのモジュールは `sashix.<name>` 名前空間にオプションを定義する。

```nix
options.sashix.foo = {
  enable = lib.mkEnableOption "foo";
  # 追加オプションがある場合はここに定義
};

config = lib.mkIf config.sashix.foo.enable {
  # 設定内容
};
```

### マシン固有値のオプション化

**boot.nix と secureboot.nix の分離**

`boot.nix` は Secure Boot に依存しない部分（カーネル・initrd・UKI）を担う。
`secureboot.nix` は lanzaboote と sbctl を担い、`boot.nix` を imports に含む。
Secure Boot が不要なマシンは `boot` のみ有効化し、`secureboot` は有効化しない。

**networking.nix**
```nix
options.sashix.networking = {
  enable   = lib.mkEnableOption "networking";
  hostName = lib.mkOption { type = lib.types.str; };  # 必須、デフォルトなし
};
```

**virtualization.nix**
```nix
options.sashix.virtualization = {
  enable       = lib.mkEnableOption "virtualization";
  username     = lib.mkOption { type = lib.types.str; };          # libvirtd グループに追加するホストユーザー名
  vmUsername   = lib.mkOption { type = lib.types.str; default = "user"; };  # VM テストユーザー名
  stateVersion = lib.mkOption { type = lib.types.str; };          # home.stateVersion (system.stateVersion と揃える)
};
```

**desktop.nix**
```nix
options.sashix.desktop = {
  enable         = lib.mkEnableOption "desktop";
  browser        = lib.mkOption { type = lib.types.str;    default = "floorp"; };
  browserPackage = lib.mkOption { type = lib.types.package; default = pkgs.floorp-bin; };
  editor         = lib.mkOption { type = lib.types.str;    default = "vim"; };
};
```

### home-manager.nix の役割

`home-manager` を受け取り、以下を行う独立モジュール。

- `home-manager.nixosModules.home-manager` を imports に含める
- `home-manager.useGlobalPkgs = lib.mkDefault true` を設定する
- `home-manager.useUserPackages = lib.mkDefault true` を設定する

### all.nix の役割

- `home-manager` と `lanzaboote` を引数で受け取る
- `./home-manager.nix` を imports に含める（個別利用との共通化）
- 各モジュールの `enable` を `lib.mkDefault true` でセットする
  (個別に `false` で上書きして除外できる)
- `warp` と `adguard` は `networkProtection` に内包されるため
  `all.nix` では `networkProtection.enable` のみ設定する
- `secureboot` は Secure Boot 不要なマシンでは無効にする必要があるため
  `all.nix` では `lib.mkDefault false` とする

### DE モジュールの規則

- `modules/<DE>/default.nix` — NixOS レベル: DE の有効化、パッケージインストール、
  `home-manager.sharedModules` へ `config/*` を登録
- `modules/<DE>/config/*.nix` — home-manager レベル: 通常の値代入 (`lib.mkDefault` 不要)
  - リスト型オプション (`bind`, `exec-once` 等) は複数モジュールにまたがっても自動マージされる
  - スカラー型オプションをここで定義した場合、ローカルの `home/<user>.nix` で上書きする場合は `lib.mkForce` を使う
- デバイス固有の設定 (モニターレイアウト、壁紙パス等) は `config/` に書かず、
  ローカルの `home/<user>.nix` に記述する

## ローカルリポジトリ (github:sashisashi/nixos) 側の使い方

### flake.nix

```nix
inputs = {
  nixpkgs.url   = "github:NixOS/nixpkgs/nixos-unstable";
  nixos-modules = { url = "github:sashisashi/sashix-modules"; inputs.nixpkgs.follows = "nixpkgs"; };
  lanzaboote.follows   = "nixos-modules/lanzaboote";
  home-manager.follows = "nixos-modules/home-manager";
};

outputs = { self, nixpkgs, nixos-modules, ... }: {
  nixosConfigurations.sato-letsnote = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # all が home-manager.nix を内包するため個別指定不要
      nixos-modules.nixosModules.modules.all
      ./configuration.nix
      { home-manager.users.sato = import ./home/sato.nix; }
    ];
  };
};
```

個別モジュールを使う場合は `home-manager` を明示的に追加する:

```nix
modules = [
  nixos-modules.nixosModules.modules.home-manager
  nixos-modules.nixosModules.modules.locale
  nixos-modules.nixosModules.modules.audio
  # ...
  ./configuration.nix
  { home-manager.users.sato = import ./home/sato.nix; }
];
```

### configuration.nix

```nix
sashix.all.enable = true;

# Secure Boot を使う場合 (all では false がデフォルト)
sashix.secureboot.enable = true;
# pkiBundle のデフォルトは "/var/lib/sbctl" のため通常は省略可
# sashix.secureboot.pkiBundle = "/var/lib/sbctl";

# 必須オプション
sashix.networking.hostName = "sato-letsnote";
sashix.virtualization = {
  username     = "sato";
  stateVersion = "25.11";
};

# 一部を無効化する場合
sashix.gnome.enable = false;

system.stateVersion = "25.11";
```

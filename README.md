# sashix-modules

sashisashi が管理する再利用可能な NixOS モジュール集。

## 概要

マシン固有でない NixOS 設定を汎用モジュールとして切り出したリポジトリ。
各モジュールは `sashix.<name>.enable` オプションで有効/無効を切り替えられる。
`sashix.all.enable = true` で全モジュールを一括有効化できる。

## モジュール一覧

| モジュール | 概要 |
|---|---|
| `all` | 全モジュール一括有効化 |
| `home-manager` | home-manager 有効化 + 共通設定 |
| `boot` | カーネル・initrd・UKI (Secure Boot 非依存) |
| `secureboot` | lanzaboote + sbctl による Secure Boot |
| `networking` | NetworkManager |
| `tailscale` | Tailscale VPN |
| `locale` | タイムゾーン・日本語ロケール・fcitx5 |
| `audio` | PipeWire |
| `nix` | flakes 有効化・自動 GC |
| `yubikey` | pcscd・GPG agent・管理ツール |
| `firewall` | Tailscale 対応ファイアウォール |
| `networkProtection` | WARP + AdGuard Home (warp / adguard を内包) |
| `desktop` | 共通デスクトップサービス・フォント |
| `virtualization` | libvirtd・build-vm 対応 |
| `gnome` | GNOME デスクトップ環境 |
| `hyprland` | Hyprland デスクトップ環境 |

詳細な設計・使い方は [DOCUMENT.md](DOCUMENT.md) を参照。

## サードパーティサービスの利用規約

以下のモジュールはサードパーティサービスを利用します。
**各モジュールを有効化することで、対応するサービスの利用規約およびプライバシーポリシーに同意したものとみなされます。**

| モジュール | サービス | 利用規約 |
|---|---|---|
| `warp` / `networkProtection` | Cloudflare WARP | [Terms](https://www.cloudflare.com/terms/) / [Privacy](https://www.cloudflare.com/privacypolicy/) |
| `adguard` / `networkProtection` | Quad9 DNS (upstream / fallback) | [Terms](https://www.quad9.net/service/policies/) |
| `tailscale` | Tailscale VPN が導入されます。 | [Terms](https://tailscale.com/terms) / [Privacy](https://tailscale.com/privacy-policy) |

## 基本的な使い方

```nix
# ローカルの flake.nix
inputs = {
  nixpkgs.url   = "github:NixOS/nixpkgs/nixos-unstable";
  nixos-modules = { url = "github:sashisashi/sashix-modules"; inputs.nixpkgs.follows = "nixpkgs"; };
  lanzaboote.follows   = "nixos-modules/lanzaboote";
  home-manager.follows = "nixos-modules/home-manager";
};
```

```nix
# configuration.nix
sashix.all.enable = true;
sashix.networking.hostName = "hostname";
sashix.virtualization = { username = "user"; stateVersion = "25.11"; };
system.stateVersion = "25.11";
```

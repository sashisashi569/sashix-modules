# NVIDIA GPU 設定 (Wayland / Hyprland 向け)
#
# 対象: Turing (RTX 20シリーズ) 以降の GPU
#       Ada Lovelace (RTX 40シリーズ) では open = true が必須
#
# カーネル互換性:
#   - NVIDIA open カーネルモジュール (open = true) は nixpkgs-unstable の
#     production ドライバが linuxPackages_latest に対してビルドされるため、
#     boot.nix が設定する linuxPackages_latest と組み合わせれば互換性は nixpkgs
#     側で保証される。
#   - そのため、以前必要だった `boot.kernelPackages = pkgs.linuxPackages_6_18;`
#     のような明示的なピン留めは通常不要。
#     カーネルアップデート直後に一時的にドライバビルドが壊れた場合のみ、
#     設定ファイル側で boot.kernelPackages を上書きして対処する。
#
# 使い方:
#   sashix.nvidia.enable = true;
{ lib, config, ... }:

{
  options.sashix.nvidia = {
    enable = lib.mkEnableOption "NVIDIA GPU configuration (Wayland / Hyprland)";
  };

  config = lib.mkIf config.sashix.nvidia.enable {

    # --- ドライバ本体 -------------------------------------------------------
    hardware.nvidia = {
      # Wayland コンポジタ (Hyprland 等) に必須
      modesetting.enable = true;

      # GPU サスペンド/レジューム の安定性向上
      powerManagement.enable = true;

      # オープンソースカーネルモジュール
      # Turing (RTX 20) 以降で使用可。Ada Lovelace (RTX 40) では推奨。
      # Maxwell / Pascal / Volta は false にすること。
      open = true;

      # production ドライバ: config.boot.kernelPackages から自動解決されるため
      # kernelPackages を変更するだけでドライバも追随する
      package = config.boot.kernelPackages.nvidiaPackages.production;
    };

    # --- ハードウェアアクセラレーション -------------------------------------
    # VA-API / OpenGL / Vulkan (32-bit 互換レイヤー含む)
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    # --- Wayland / NVIDIA 向け環境変数 (Hyprland 最適化) -------------------
    environment.sessionVariables = {
      NIXOS_OZONE_WL            = "1";
      GBM_BACKEND               = "nvidia-drm";
      __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      WLR_NO_HARDWARE_CURSORS   = "1";
      LIBVA_DRIVER_NAME         = "nvidia";
      XDG_SESSION_TYPE          = "wayland";
    };

  };
}

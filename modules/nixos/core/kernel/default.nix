{ config, pkgs, lib, inputs, ... }:
let
  gaming = if config.mx.programs.games.enable then import ./gaming.nix { lib = lib; } else {};
  media = if config.mx.programs._studio.enable then import ./media.nix { lib = lib; } else {};

  cfg = config.mx.kernel;
in
{
  options.mx.kernel = {
    cachyos-kernel = {
      enable = lib.mkEnableOption "Enable cachyOS Kernel";
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.cachyosKernels.linuxPackages_cachyos;
        description = "CachyOS kernel package";
      };
    };
  };

  config = {
    boot.kernelPackages = lib.mkIf cfg.cachyos-kernel.enable
  (lib.mkForce (pkgs.linuxPackagesFor cfg.cachyos-kernel.package));

    boot.supportedFilesystems.zfs = false;
    boot.zfs.package = lib.mkIf cfg.cachyos-kernel.enable
    cfg.cachyos-kernel.package.zfs_cachyos;
    nix.settings.substituters = []
    ++ lib.optionals cfg.cachyos-kernel.enable [ "https://attic.xuyh0120.win/lantian" ];
    nix.settings.trusted-public-keys = []
     ++ lib.optionals cfg.cachyos-kernel.enable [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
    nixpkgs.overlays = [
      inputs.nix-cachyos-kernel.overlays.pinned  # toujours appliqué
      (self: super: lib.optionalAttrs (!cfg.cachyos-kernel.enable) {
        linuxPackages = super.linuxPackages // {
          kernel = super.linuxPackages.kernel.override {
            structuredExtraConfig = gaming // media;
          };
        };
      })
    ];
  };
}

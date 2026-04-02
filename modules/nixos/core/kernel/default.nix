{ config, lib, inputs, ... }:
let
  gaming = if config.mx.programs.games.enable then import ./gaming.nix { lib = lib; } else {};
  media = if config.mx.programs._studio.enable then import ./media.nix { lib = lib; } else {};
in
{
  nixpkgs.overlays = [
    (if config.mx.programs.games.cachyos-kernel.enable then
      inputs.nix-cachyos-kernel.overlays.pinned
    else (self: super: {
      linuxPackages = super.linuxPackages.override {
        kernel = super.linuxPackages.kernel.override {
          structuredExtraConfig = gaming // media;
        };
      };
    }))
  ];
}

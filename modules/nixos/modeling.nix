{ pkgs, config, ... }:
{
  nixpkgs.config.blender.acceleration = config.winter.hardware.gpu.acceleration;

  environment.systemPackages = with pkgs; [
    (import ../../pkgs/blender.nix {
      inherit pkgs;
      acceleration = config.winter.hardware.gpu.acceleration;
    })
    bambu-studio
  ];
}

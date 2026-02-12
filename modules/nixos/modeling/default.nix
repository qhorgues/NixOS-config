{ pkgs, config, lib, ... }:

let
  cfg = config.winter.programs.modeling;
in
{
  options.winter.programs.modeling = {
    enable = lib.mkEnableOption "Enable modeling software";
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config.blender.acceleration = config.winter.hardware.gpu.acceleration;

    environment.systemPackages = with pkgs; [
      (import ../../../pkgs/blender.nix {
        inherit pkgs;
        acceleration = config.winter.hardware.gpu.acceleration;
      })
      bambu-studio
    ];
  };
}

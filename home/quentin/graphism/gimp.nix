{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.graphism.gimp;
in
{
  options.mx.programs.graphism.gimp = {
    enable = lib.mkEnableOption "Enable gimp tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gimp
      eyedropper
    ];
  };
}

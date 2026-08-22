{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.graphism.krita;
in
{
  options.mx.programs.graphism.krita = {
    enable = lib.mkEnableOption "Enable krita tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      krita
      eyedropper
    ];
  };
}

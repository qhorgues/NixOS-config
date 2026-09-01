{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.graphism.inkscape;
in
{
  options.mx.programs.graphism.inkscape = {
    enable = lib.mkEnableOption "Enable inkscape tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      inkscape
      eyedropper
    ];
  };
}

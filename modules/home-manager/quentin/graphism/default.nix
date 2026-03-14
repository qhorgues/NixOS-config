{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.graphism;
in
{
  options.mx.programs.graphism = {
    enable = lib.mkEnableOption "Enable graphism tools";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gimp3
      inkscape
      krita
      eyedropper
    ];
  };
}

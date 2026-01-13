{ pkgs, config, lib, ... }:

let
  cfg = config.winter.programs.graphism;
in
{
  options.winter.programs.graphism = {
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

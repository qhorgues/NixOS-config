{ config, lib, ... }:

let
  cfg = config.mx.programs.graphism;
in
{
  options.mx.programs.graphism = {
    enable = lib.mkEnableOption "Enable all graphism tools";
  };

  imports = [
    ./gimp.nix
    ./inkscape.nix
    ./krita.nix
  ];

  config = lib.mkIf cfg.enable {
    mx.programs.graphism = {
      krita.enable = lib.mkDefault true;
      gimp.enable = lib.mkDefault true;
      inkscape.enable = lib.mkDefault true;
    };
  };
}

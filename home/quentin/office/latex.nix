{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.office.latex;
in
{
  options.mx.programs.office.latex = {
    enable = lib.mkEnableOption "Install latex office suite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      texliveFull
      texstudio
      hunspellDicts.fr-any
      hunspellDicts.en-us
    ];
  };
}

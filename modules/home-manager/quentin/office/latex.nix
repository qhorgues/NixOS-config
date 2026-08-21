{ pkgs, config, lib, qhorgues-config, ... }:

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
      qhorgues-config.packages.${pkgs.stdenv.hostPlatform.system}.texstudio
      hunspellDicts.fr-any
      hunspellDicts.en-us
    ];
  };
}

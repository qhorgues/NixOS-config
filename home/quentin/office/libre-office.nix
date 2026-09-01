{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.office.libre-office;
in
{
  options.mx.programs.office.libre-office = {
    enable = lib.mkEnableOption "Install libre office suite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      libreoffice-fresh
      hunspellDicts.fr-any
      hunspellDicts.en-us
    ];
  };
}

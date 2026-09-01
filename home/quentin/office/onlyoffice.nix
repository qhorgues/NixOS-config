{ pkgs, config, lib, ... }:

let
  cfg = config.mx.programs.office.onlyoffice;
in
{
  options.mx.programs.office.onlyoffice = {
    enable = lib.mkEnableOption "Install only office suite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      onlyoffice-desktopeditors
      hunspellDicts.fr-any
      hunspellDicts.en-us
    ];
  };
}

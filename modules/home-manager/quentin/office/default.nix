{ config, lib, ... }:

let
  cfg = config.mx.programs.office;
in
{
  options.mx.programs.office = {
    enable = lib.mkEnableOption "Enable all office tools";
  };

  imports = [
    ./latex.nix
    ./onlyoffice.nix
    ./libre-office.nix
  ];

  config = lib.mkIf cfg.enable {
    mx.programs.office = {
      latex.enable = lib.mkDefaut true;
      onlyoffice.enable = lib.mkDefaut true;
      libre-office.enable = lib.mkDefaut true;
    };
  };
}

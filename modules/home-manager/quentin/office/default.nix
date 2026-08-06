{ pkgs, config, lib, qhorgues-config, ... }:

let
  cfg = config.mx.programs.office;
in
{
  options.mx.programs.office = {
    enable = lib.mkEnableOption "Install office suite";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      texliveFull
      qhorgues-config.packages.${pkgs.stdenv.hostPlatform.system}.texstudio
      gsettings-desktop-schemas
      onlyoffice-desktopeditors
      libreoffice-fresh
      hunspellDicts.fr-any
      hunspellDicts.en-us
    ];
  };
}

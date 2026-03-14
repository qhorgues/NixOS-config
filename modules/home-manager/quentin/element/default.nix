{ config, lib, pkgs, ... }:

let
  cfg = config.mx.programs.element;
  flatpakApp = import ../flatpak/app.nix {
    inherit pkgs lib;
    enableApp = cfg.enable;
  };
in
{
  options.mx.programs.element = {
    enable = lib.mkEnableOption "Install Client client";
  };

  config =  {
    mx.services.flatpak.enable = if cfg.enable then lib.mkForce true else lib.mkDefault false;
    home.activation.element = flatpakApp "im.riot.Riot";
  };
}

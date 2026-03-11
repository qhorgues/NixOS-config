{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.element;
  flatpakApp = import ../flatpak/app.nix {
    inherit pkgs lib;
    enableApp = cfg.enable;
  };
in
{
  options.winter.programs.element = {
    enable = lib.mkEnableOption "Install Client client";
  };

  config =  {
    winter.services.flatpak.enable = if cfg.enable then lib.mkForce true else lib.mkDefault false;
    home.activation.element = flatpakApp "im.riot.Riot";
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.element;
  flatpakApp = import ../flatpak/app.nix { inherit pkgs lib;};
in
{
  options.winter.programs.element = {
    enable = lib.mkEnableOption "Install Element client";
  };

  config = lib.mkIf cfg.enable {
    winter.services.flatpak.enable = true;
    home.activation.element = flatpakApp "im.riot.Riot";
  };
}

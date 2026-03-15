{ config, lib, pkgs, ... }:

let
  cfg = config.mx.programs.discord;
  flatpakApp = import ../flatpak/app.nix {
    inherit pkgs lib;
    enableApp = cfg.enable;
  };
in
{
  options.mx.programs.discord = {
    enable = lib.mkEnableOption "Install Discord client";
  };

  config =  {
    mx.services.flatpak.enable = if cfg.enable then lib.mkForce true else lib.mkDefault false;
    home.activation.discord = flatpakApp "com.discordapp.Discord";
  };
}

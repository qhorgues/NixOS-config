{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.discord;
  flatpakApp = import ../flatpak/app.nix {
    inherit pkgs lib;
    enableApp = cfg.enable;
  };
in
{
  options.winter.programs.discord = {
    enable = lib.mkEnableOption "Install Discord client";
  };

  config =  {
    winter.services.flatpak.enable = if cfg.enable then lib.mkForce true else lib.mkDefault false;
    home.activation.discord = flatpakApp "com.discordapp.Discord";
  };
}

{ config, lib, pkgs, ... }:

let
  cfg = config.winter.programs.discord;
  flatpakApp = import ../flatpak/app.nix { inherit pkgs lib;};
in
{
  options.winter.programs.discord = {
    enable = lib.mkEnableOption "Install Discord client";
  };

  config = lib.mkIf cfg.enable {
    winter.services.flatpak.enable = true;
    home.activation.discord = flatpakApp "com.discordapp.Discord";
  };
}

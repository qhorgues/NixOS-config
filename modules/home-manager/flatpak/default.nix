{ pkgs, config, lib, ... }:

let
  cfg = config.winter.services.flatpak;
in
{
  options.winter.services.flatpak = {
    enable = lib.mkEnableOption "Enable flatpak service";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      flatpak
    ];

    home.sessionVariables = {
      XDG_DATA_DIRS = "$XDG_DATA_DIRS:${config.home.homeDirectory}/.local/share/flatpak/exports/share:/usr/share:/var/lib/flatpak/exports/share";
    };

    home.activation.flatpak = lib.hm.dag.entryAfter ["writeBoundary"]
    ''
      ${pkgs.flatpak}/bin/flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
      ${pkgs.flatpak}/bin/flatpak update --user -y
    '';
  };
}

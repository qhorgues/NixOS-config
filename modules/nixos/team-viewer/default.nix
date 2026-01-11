{ pkgs, config, lib, ... }:

let
  cfg = config.winter.programs.team-viewer;
in
{
  options.winter.programs.team-viewer.enable = lib.mkEnableOption "Enable Team Viewer";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.teamviewer ];
    services.teamviewer.enable = true;
  };
}

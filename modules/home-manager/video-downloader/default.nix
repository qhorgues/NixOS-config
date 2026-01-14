{ config, pkgs, lib, ... }:
let
  cfg = config.winter.programs.video-downloader;
in
{
  options.winter.programs.video-downloader = {
    enable = lib.mkEnableOption "Install video downloader";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      video-downloader
    ];
  };
}

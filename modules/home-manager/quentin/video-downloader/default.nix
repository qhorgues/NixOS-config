{ config, pkgs, lib, ... }:
let
  cfg = config.mx.programs.video-downloader;
in
{
  options.mx.programs.video-downloader = {
    enable = lib.mkEnableOption "Install video downloader";
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      video-downloader
    ];
  };
}

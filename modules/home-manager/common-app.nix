{ pkgs, ... }:
{
  home.packages = with pkgs; [
    video-downloader
  ];
}

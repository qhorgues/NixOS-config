{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager/firefox
    ../../modules/home-manager/kdrive.nix
    ../../modules/home-manager/graphism.nix
    ../../modules/home-manager/gnome.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/shell.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/vm-manager.nix
    ../../modules/home-manager/gaphor.nix
  ];

  home.username = "quentin";
  home.homeDirectory = "/home/quentin";
  nixpkgs.config.allowUnfree = true;
  # home.enableNixpkgsRelease = false;
  home.keyboard = {
    layout = "fr";
    variant = "fr";
  };
  home.packages = with pkgs; [
    discord
    rhythmbox

    fastfetch
    htop
    dconf-editor

    mysql-workbench
    gnome-music
  ];

  home.stateVersion = "25.05";
}

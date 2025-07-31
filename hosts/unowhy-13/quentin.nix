{ pkgs, ... }:
{
  imports = [
    ../../modules/home-manager/firefox
    ../../modules/home-manager/kdrive.nix
    ../../modules/home-manager/gnome.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/shell.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/flake-script.nix
  ];

  winter = {
    update = {
        flake_path = "/home/quentin/config";
        flake_config = "unowhy-13";
    };
    auto-update.enable = true;
  };

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

    fastfetch
    htop
    dconf-editor
  ];

  home.stateVersion = "25.05";
}

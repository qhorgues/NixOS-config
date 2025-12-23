{ pkgs, system-version, winter, ... }:
{
  imports = [
    ../../modules/home-manager/firefox
    ../../modules/home-manager/kdrive.nix
    ../../modules/home-manager/graphism.nix
    ../../modules/home-manager/gnome
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/shell.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/vm-manager.nix
    ../../modules/home-manager/flake-script.nix
    ../../modules/home-manager/modeling.nix {inherit winter;}
    ./home-manager/zed-remote-folder.nix
  ];

  winter = {
    update = {
        flake_path = "/home/quentin/config";
        flake_config = "desktop-acer-n50";
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

  home.stateVersion = system-version;
}

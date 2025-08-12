{ pkgs, system-version, ... }:
{
  imports = [
    ../../modules/home-manager/firefox
    ../../modules/home-manager/gnome.nix
    ../../modules/home-manager/office.nix
  ];

  home.username = "elise";
  home.homeDirectory = "/home/elise";
  nixpkgs.config.allowUnfree = true;
  # home.enableNixpkgsRelease = false;
  home.keyboard = {
    layout = "fr";
    variant = "fr";
  };
  home.packages = with pkgs; [
  ];

  home.stateVersion = system-version;
}

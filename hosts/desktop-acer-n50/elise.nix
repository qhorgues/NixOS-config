{ ... }:
{
  imports = [
    ../../modules/home-manager
    ../../modules/home-manager/firefox
    ../../modules/home-manager/gnome
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
}

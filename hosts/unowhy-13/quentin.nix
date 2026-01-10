{ ... }:
{
  imports = [
    ../../modules/home-manager
    ../../modules/home-manager/linux-base-app.nix
    ../../modules/home-manager/common-app.nix
    ../../modules/home-manager/firefox
    ../../modules/home-manager/gnome
    ../../modules/home-manager/kdrive.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/dev.nix
    ../../modules/home-manager/shell.nix
    ../../modules/home-manager/office.nix
    ../../modules/home-manager/thunderbird.nix
    ../../modules/home-manager/flake-script.nix
    ../../modules/home-manager/discord.nix
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
}

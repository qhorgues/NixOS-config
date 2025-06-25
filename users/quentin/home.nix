{ pkgs, ... }: {

  imports = [
    ./git.nix
    ./firefox.nix
    ./gnome.nix
    ./shell.nix
    ./zed.nix
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
    # openrgb

    # Desktop
    texliveFull
    texstudio
    # python312Packages.pygments

    onlyoffice-bin
    # libreoffice-fresh

    kdePackages.kdenlive
    rhythmbox

    thunderbird-latest-bin

    # Base gnome app
    gnome-console
    gnome-text-editor
    gnome-calculator
    showtime
    evince
    file-roller
    nautilus
    baobab
    loupe
    eyedropper

    # Tools
    fastfetch
    htop
    gnome-tweaks
    dconf-editor
    gnome-extension-manager
    steam-run
  ];

  home.stateVersion = "25.05";
}

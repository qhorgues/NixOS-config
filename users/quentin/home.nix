{ pkgs, lib, pkgs-unstable, ... }: {

  imports = [
    ./git.nix
    ./gnome.nix
    ./shell.nix
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

    # C / C++
    # gcc
    # clang-tools
    # clang
    # cmake
    # gnumake

    # Rust
    # cargo
    # rustc
    # rustup
    # rust-analyzer

    # Python
    # python3
    # uv
    # ruff

    # Games
    adwsteamgtk
    discord
    # openrgb

    # Desktop
    texliveFull
    texstudio
    # python312Packages.pygments

    # libreoffice-fresh
    onlyoffice-desktopeditors

    # Graphism
    inkscape
    gimp3
    krita

    kdePackages.kdenlive
    rhythmbox

    thunderbird

    # VM
    virt-manager

    # Dev
    pkgs-unstable.zed-editor
    zeal
    git

    # Nix
    nixd # Nix language server for zeditor
    nil

    # Base gnome app
    gnome-console
    gnome-text-editor
    gnome-calculator
    totem
    evince
    file-roller
    nautilus
    baobab

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

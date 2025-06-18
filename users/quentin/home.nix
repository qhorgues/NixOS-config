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

    discord
    # openrgb

    # Desktop
    texliveFull
    texstudio
    # python312Packages.pygments

    libreoffice-fresh

    kdePackages.kdenlive
    rhythmbox

    thunderbird

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

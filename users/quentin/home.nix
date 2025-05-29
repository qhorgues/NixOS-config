{ pkgs, lib, pkgs-unstable, ... }: {
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
  };
  home.username = "quentin";
  home.homeDirectory = "/home/quentin";
  nixpkgs.config.allowUnfree = true;
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
  ];
}

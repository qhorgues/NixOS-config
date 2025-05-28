{ config, pkgs, lib, unstable, ... }: {
  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.vanilla-dmz;
    name = "Vanilla-DMZ";
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
    python312Packages.pygments

    # libreoffice-fresh
    onlyoffice-desktopeditors

    # Graphism
    inkscape
    gimp3
    krita

    kdePackages.kdenlive
    rhythmbox

    thunderbird
    gnomeExtensions.removable-drive-menu
    gnomeExtensions.caffeine
    gnomeExtensions.user-themes

    # VM
    virt-manager

    # Dev
    unstable.zed-editor
    zeal
    git

    # Nix
    nixd # Nix language server for zeditor
    nil

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
    # python312Packages.pygments # For minted

    # libreoffice-fresh
    onlyoffice-desktopeditors

    # Graphism
    inkscape
    gimp3
    krita

    kdePackages.kdenlive
    rhythmbox

    gnome-console
    gnome-calculator
    gnome-text-editor
    file-roller
    nautilus
    baobab
    totem
    evince
    loupe

    thunderbird
  ];

  home.stateVersion = config.system.nixos.release;
}

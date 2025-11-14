{ pkgs, pkgs-unstable, config, ... }:
{
  home.packages = with pkgs; [
    pkgs-unstable.zed-editor
    zeal
    git

    # C / C++
    clang-tools
    clang
    cmakeWithGui
    gnumake

    # Rust
    cargo
    rustc
    rust-analyzer

    # Node
    bun
    nodejs

    # Python
    python3
    uv
    ruff

    nil
    nixd # Nix language server for zeditor
    alejandra

    gaphor
    mysql-workbench
    filezilla

    # PHP / Laravel
    php84
    php84Packages.composer

    # Gnome app dev suite
    cambalache
    gnome-builder
    flatpak
    flatpak-builder
  ];

  home.sessionPath = [
    "${config.home.homeDirectory}/.bun/bin"
  ];

}

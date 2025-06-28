{ pkgs, pkgs-unstable, ... }:
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

    # Python
    python3
    uv
    ruff

    nixd # Nix language server for zeditor
  ];

}

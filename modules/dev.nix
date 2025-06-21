{ pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs-unstable.zed-editor
    zeal
    git

    # C / C++
    gcc
    clang-tools
    clang
    cmake
    cmakeWithGui
    gnumake

    # Rust
    cargo
    rustc
    rustup
    rust-analyzer

    # Python
    python3
    uv
    ruff

    nixd # Nix language server for zeditor
    nil
  ];

}

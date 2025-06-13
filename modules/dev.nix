{ pkgs, pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs; [
    pkgs-unstable.zed-editor
    zeal
    git
    cmakeWithGui

    nixd # Nix language server for zeditor
    nil

    clang-tools
  ];

}

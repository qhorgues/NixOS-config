{ pkgs, lib, ... }:

let
  flatpakApp = import ./flatpak/app.nix { inherit pkgs lib;};
in
{
  imports = [
    ./flatpak
  ];

  home.activation.discord = flatpakApp "com.discordapp.Discord";
}

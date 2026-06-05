{ pkgs, lib, ... }:
{
  programs.nix-ld = {
    enable = lib.mkDefault true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib # libstdc++
      zlib # libz
      glib # libglib
    ];
  };
}

{ config, pkgs, lib, ... }:

{
  security.rtkit.enable = lib.mkDefault true;
  security.apparmor.enable = lib.mkDefault false;
}

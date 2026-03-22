{ config, lib, pkgs, ... }:

let
  cgpu = config.mx.hardware.gpu;
in
{
  imports = [
    ./boot.nix
    ./fix.nix
    ./options
    ./security.nix
    ./sound.nix
    ./update.nix
    ./zram.nix
    ./powersave.nix
    ./bluetooth.nix
    ./ios-connect.nix
    ./ssd.nix
    ./network.nix
    ./gpu-computing.nix
    ./nvidia.nix
    ./gpu-acceleration.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = config.system.nixos.release;
  services.xserver.videoDrivers = [
   (if cgpu.vendor == "amd" then "amdgpu"
     else if cgpu.vendor == "intel" || cgpu.vendor == "nvidia" then cgpu.vendor else "auto") ];

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "fr_FR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  console.keyMap = "fr";

  programs.nix-ld = {
      enable = lib.mkDefault true;
      libraries = with pkgs; [
        stdenv.cc.cc.lib # libstdc++
        zlib # libz
        glib # libglib
      ];
    };

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };
  systemd.tmpfiles.rules = [
    "d /media 0755 root root -"
  ];

  documentation.nixos.enable = false;

  hardware.fw-fanctrl.enable = config.mx.hardware.framework-fan-ctrl.enable;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
}

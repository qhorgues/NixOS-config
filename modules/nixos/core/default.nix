{ config, lib, ... }:

{
  imports = [
    ./boot.nix
    ./fix.nix
    ./options
    ./security.nix
    ./update.nix
    ./zram.nix
    ./powersave.nix
    ./ssd.nix
    ./gpu-computing.nix
    ./nvidia.nix
    ./agenix.nix
    ./kernel

    # Desktop only
    ./sound.nix
    ./network.nix
    ./gpu-acceleration.nix
    ./ios-connect.nix
    ./bluetooth.nix
    ./nix-ld.nix
    ./filesystem.nix
  ];
  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = config.system.nixos.release;

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

  documentation.nixos.enable = false;

  hardware.fw-fanctrl.enable = config.mx.hardware.framework-fan-ctrl.enable;
  hardware.enableRedistributableFirmware = true;
  hardware.enableAllFirmware = true;
}

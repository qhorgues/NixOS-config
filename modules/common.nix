{ config, pkgs, lib, ... }:

{
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

  networking.networkmanager.enable = lib.mkDefault true;
  networking.firewall.enable = lib.mkForce true;

  console.keyMap = "fr";

  programs.nix-ld.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    home-manager
  ];

  services.devmon.enable = true;
  services.gvfs.enable = true;
  services.udisks2.enable = true;
}

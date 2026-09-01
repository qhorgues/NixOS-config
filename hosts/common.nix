{ pkgs, lib, agenix, coe33, ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      coe33 = coe33.packages.${prev.stdenv.hostPlatform.system}.default;
    })
  ];

  age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  environment.systemPackages = [
    agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };

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

  users.users.quentin = {
    isNormalUser = true;
    initialPassword = "1234";
    description = "Quentin Horgues";
    extraGroups = [ "wheel" "networkmanager" ];
    shell = pkgs.zsh;
  };
  programs.zsh.enable = true;
}

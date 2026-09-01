{ pkgs, nixos-hardware, ... }:

let
    monitorsXmlContent = builtins.readFile ./monitors.xml;
    monitorsConfig = pkgs.writeText "gdm_monitors.xml" monitorsXmlContent;
in
{
    imports = [
        nixos-hardware.nixosModules.common-gpu-nvidia-nonprime
        nixos-hardware.nixosModules.common-pc-ssd
        nixos-hardware.nixosModules.common-pc
        ./hardware-configuration.nix
    ];

    hardware.nvidia.open = false;
    networking.hostName = "desktop-quentin";

    systemd.tmpfiles.rules = [
        "L+ /var/lib/gdm/seat0/config/monitors.xml - gdm gdm - ${monitorsConfig}"
    ];

    mx = {
      core.network.security-mode = false;
      hardware = {
        cpu.vendor = "intel"; # "intel"/"amd"
        ssd.lists = [ "/" "/mnt/Games" ]; # All mountpoint with a SSD
        gpu = {
          vendor = "nvidia"; #  "amd"/"nvidia"/"intel"
          generation = "pascal"; # Use chipset reférence or null
          # (ex: Nvidia: "ada-lovelace", "blackwell",
          #               "ampere", "pascal",
          #  AMD: "rdna4", "gcn-4-gen", "gcn-1-gen")
          compute.backend = "cuda"; #  "rocm"/"cuda"/"intel"/"cpu"
        };
        bluetooth.enable = true;
      };
      desktop = "gnome"; # "cli"/"gnome"/"plasma"/"lxqt"
      fonts.enable = true;
      programs = { # Enable some system app
        home-manager = {
          enable = true;
          users = {
            quentin.configPath = ./quentin.nix;
          };
        };
        games = {
          steam.enable = true;
          users = [ "quentin" ]; # Allowed user for gamemode
          game_lib_dirs = [
            "/mnt/Games"
          ];
          lsfg.enable = false;
          heroic.enable = false;
          lutris.enable = false;
          umu.enable = false;

          gamescopeSession = {
            enable = true;
            screen = {
              width = 1920;
              height = 1080;
            };
          };
        };
      };
    };

    users.users.quentin = {
      isNormalUser = true;
      initialPassword = "1234";
      description = "Quentin Horgues";
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
    programs.zsh.enable = true;

    users.users."elise"= {
      isNormalUser = true;
      initialPassword = "1234";
      description = "Elise Horgues";
      extraGroups = [ "networkmanager" ];
    };
}

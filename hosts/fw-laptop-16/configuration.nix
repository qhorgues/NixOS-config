{ self, inputs, pkgs-unstable, lib, ... }:
{
  imports = [
    inputs.nixos-hardware.nixosModules.framework-16-7040-amd
    ./hardware-configuration.nix
    ../../modules/nixos/fonts
    ../../modules/nixos/gnome
    ../../modules/nixos/boot.nix
    ../../modules/nixos/common.nix
    ../../modules/nixos/main-users.nix
    ../../modules/nixos/sound.nix
    ../../modules/nixos/security.nix
    ../../modules/nixos/zram.nix
    ../../modules/nixos/games.nix
    ../../modules/nixos/update.nix
    ../../modules/nixos/disable-bluetooth.nix
    ../../modules/nixos/vm.nix
    ../../modules/nixos/ollama.nix
    ../../modules/nixos/powersave.nix
    ../../modules/nixos/ios-connect.nix
    ../../modules/nixos/mariadb.nix
    #../../modules/nixos/phpmyadmin.nix
  ];

  networking.hostName = "fw-laptop-quentin";

  fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];
  fileSystems."/mnt/Games" =
  { device = "/dev/disk/by-uuid/1b35568b-4447-4c80-9880-4b359d4ecb6c";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
  zramSwap.memoryPercent = 20;
  services.udev.extraRules = ''
    # Framework Laptop 16 Keyboard Module - ANSI
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0012", ATTR{power/wakeup}="disabled"

    # Framework Laptop 16 RGB Macropad
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0013", ATTR{power/wakeup}="disabled"

    # Framework Laptop 16 Numpad Module
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0014", ATTR{power/wakeup}="disabled"

    # Framework Laptop 16 Keyboard Module - ISO
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="32ac", ATTRS{idProduct}=="0018", ATTR{power/wakeup}="disabled"
  '';

  programs.dconf = {
    enable = true;
    profiles.gdm.databases = [{
        settings."org/gnome/desktop/interface" = {
          scaling-factor = lib.gvariant.mkUint32 2;
          text-scaling-factor = 0.8;
        };
    }];
    profiles.users.databases = [{
      settings = {
        "org/gnome/desktop/interface" = {
            scaling-factor = lib.gvariant.mkUint32 2;
            text-scaling-factor =  0.8;
        };
      };
    }];
  };

  winter.main-user = {
    enable = true;
    userName = "quentin";
    userFullName = "Quentin Horgues";
  };

  winter.ollama.acceleration = "rocm";

  home-manager = {
    extraSpecialArgs = { inherit self inputs pkgs-unstable; };
    users = {
      "quentin" = import ./quentin.nix;
    };
  };

  winter.vm = {
    users = [ "quentin" ];
  };


  # services.phpmyadmin = {
  #   enable = true;
  #   vhost = "phpmyadmin.local";
  #   enableHostEntry = true;
  # };

}

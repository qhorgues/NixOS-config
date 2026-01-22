{ self, inputs, pkgs, pkgs-unstable, ... }:
{
    imports = [
        inputs.nixos-hardware.nixosModules.framework-16-7040-amd
        ./hardware-configuration.nix
    ];

    winter = {
      hardware = {
        ssd.lists = [ "/" "/mnt/Games" ];
        framework-fan-ctrl.enable = true;
        gpu = {
          vendor = "amdgpu";
          acceleration = "rocm";
          frame-generation.enable = true;
          generation = "rdna3";
        };
        bluetooth.enable = true;
      };
      main-user = {
        enable = true;
        userName = "quentin";
        userFullName = "Quentin Horgues";
      };
      gnome = {
        enable = true;
        scaling = 2;
        text-scaling = 0.7;
      };
      services = {
        vm = {
          enable = false;
          users = [ "quentin" ];
        };
        docker = {
          enable = true;
          users = [ "quentin" ];
        };
        mariadb.enable = false;
        postgresql.enable = false;
      };
      programs = {
        games.enable = true;
      };
    };

    networking.hostName = "fw-laptop-quentin";

    fileSystems."/mnt/Games" =
    { device = "/dev/disk/by-uuid/1b35568b-4447-4c80-9880-4b359d4ecb6c";
        fsType = "ext4";
    };

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



    programs.adb.enable = true;
    users.users."quentin".extraGroups = [ "adbusers" ];

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
          inherit self inputs pkgs pkgs-unstable;
      };
      users = {
        "quentin" = import ./quentin.nix;
      };
    };
}

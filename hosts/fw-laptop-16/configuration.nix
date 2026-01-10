{ self, inputs, pkgs, pkgs-unstable, ... }:
{
    imports = [
        inputs.nixos-hardware.nixosModules.framework-16-7040-amd
        ./hardware-configuration.nix
        ../../modules/nixos/core
        ../../modules/nixos/fonts
        ../../modules/nixos/gnome
        ../../modules/nixos/main-users.nix
        ../../modules/nixos/games.nix
        ../../modules/nixos/disable-bluetooth.nix
        # ../../modules/nixos/ollama.nix
        # ../../modules/nixos/sunshine-virtual-display.nix
        # ../../modules/nixos/ios-connect.nix
        # ../../modules/nixos/mariadb.nix
        # ../../modules/nixos/modeling.nix
        # ../../modules/nixos/docker.nix
        # ../../modules/nixos/vm.nix
        # ../../modules/nixos/winapps.nix
        # ../../modules/nixos/powersave.nix
        # ../../modules/nixos/team-viewer.nix
    ];

    networking.hostName = "fw-laptop-quentin";

    boot.kernelParams = [ "acpi_osi=Linux" ];

    fileSystems."/".options = [ "noatime" "nodiratime" "discard" "defaults" ];
    fileSystems."/mnt/Games" =
    { device = "/dev/disk/by-uuid/1b35568b-4447-4c80-9880-4b359d4ecb6c";
        fsType = "ext4";
        options = [ "noatime" "nodiratime" "discard" ];
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

    winter = {
      hardware = {
        framework-fan-ctrl.enable = true;
        gpu = {
          vendor = "amdgpu";
          acceleration = "rocm";
          frame-generation.enable = true;
          generation = "rdna3";
        };
      };
      main-user = {
        enable = true;
        userName = "quentin";
        userFullName = "Quentin Horgues";
      };
      gnome = {
        scaling = 2;
        text-scaling = 0.7;
      };
      vm = {
        users = [ "quentin" ];
      };
    };

    programs.adb.enable = true;
    users.users."quentin".extraGroups = [ "adbusers" ];

    home-manager = {
      extraSpecialArgs = {
          inherit self inputs pkgs pkgs-unstable;
      };
      users = {
        "quentin" = import ./quentin.nix;
      };
    };
}

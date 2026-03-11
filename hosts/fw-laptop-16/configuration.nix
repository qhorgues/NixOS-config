{ self, inputs, pkgs, pkgs-unstable, ... }:
{
    imports = [
        inputs.nixos-hardware.nixosModules.framework-16-7040-amd
        ./hardware-configuration.nix
    ];

    winter = {
      core.network.security-mode = true;
      hardware = {
        ssd.lists = [ "/" "/mnt/Games" ];
        framework-fan-ctrl.enable = true;
        gpu = {
          vendor = "amd";
          acceleration = "rocm";
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
          enable = true;
          users = [ "quentin" ];
        };
        docker = {
          enable = true;
          users = [ "quentin" ];
        };
        lamp.enable = true;
        postgresql.enable = false;
        llm.enable = true;
        printing.enable = true;
      };
      programs = {
        modeling.enable = false;
        obs-studio.enable = true;
        games = {
          enable = true;
          force-fsr4-for-rdna3 = true;
          gamemode.users = [ "quentin" ];
        };
        team-viewer.enable = false;
        arduino = {
          enable = false;
          users = [ "quentin" ];
        };
      };
    };

    networking.hostName = "fw-laptop-quentin";

    fileSystems."/mnt/Games" =
    { device = "/dev/disk/by-uuid/1b35568b-4447-4c80-9880-4b359d4ecb6c";
        fsType = "ext4";
    };

    boot.kernelParams = [
      "amdgpu.runpm=0" "amdgpu.bapm=0" "amdgpu.aspm=0" "pcie_aspm=off"
    ];

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

    # Fix for AMD GPU crash
    nixpkgs.overlays = [
      (self: super:
        let
          version = "20250808";
        in
        {
        linux-firmware = super.linux-firmware.overrideAttrs (old: {
          version = version;
          src = super.fetchurl {
            url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz";
            sha256 = "sha256-wClVG0WhWSbJ16XfGgtUAEQGTxkVfFf8Edkf0Kreg38=";
          };
          patches = [];
        });
      })
    ];

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

    environment.systemPackages = [
      pkgs.git
    ];
}

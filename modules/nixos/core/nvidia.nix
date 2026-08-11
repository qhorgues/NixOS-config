{ pkgs, lib, config, ... }:

let
  nvidia = config.mx.hardware.gpu.vendor == "nvidia";

  legacy-fermi = config.mx.hardware.gpu.generation ==  "fermi";
  legacy-kepler = config.mx.hardware.gpu.generation == "kelper";
  old-gpu = builtins.elem config.mx.hardware.gpu.generation [  "maxwell" "pascal" ];

  close-nvidia = legacy-fermi || legacy-kepler || old-gpu;

  nvidia595Driver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "595.58.03";
    sha256_64bit = "sha256-jA1Plnt5MsSrVxQnKu6BAzkrCnAskq+lVRdtNiBYKfk=";
    sha256_aarch64 = "sha256-hzzIKY1Te8QkCBWR+H5k1FB/HK1UgGhai6cl3wEaPT8=";
    openSha256 = "sha256-6LvJyT0cMXGS290Dh8hd9rc+nYZqBzDIlItOFk8S4n8=";
    settingsSha256 = "sha256-2vLF5Evl2D6tRQJo0uUyY3tpWqjvJQ0/Rpxan3NOD3c=";
    persistencedSha256 = "sha256-AtjM/ml/ngZil8DMYNH+P111ohuk9mWw5t4z7CHjPWw=";
  };

in
{
  config = lib.mkMerge [
    (
      lib.mkIf nvidia {
        hardware.nvidia.package =
          (
          if old-gpu then
            config.boot.kernelPackages.nvidiaPackages.legacy_580
          else if legacy-kepler then
            config.boot.kernelPackages.nvidiaPackages.legacy_470
          else if legacy-fermi then
            config.boot.kernelPackages.nvidiaPackages.legacy_390
          else
            nvidia595Driver
          );
      }
    )
    (
      lib.mkIf (nvidia && close-nvidia) {
        hardware.nvidia.powerManagement.enable = true;
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
        hardware.nvidia.open = false;
      }
    )
    (
      lib.mkIf nvidia {
        boot.kernelParams = [
          "nvidia.NVreg_PreserveVideoMemoryAllocations=1"
          "NVreg_TemporaryFilePath=/var/tmp"
        ];

        systemd = {
          services."gnome-suspend" = {
            description = "suspend gnome shell";
            before = [
              "systemd-suspend.service"
              "systemd-hibernate.service"
              "nvidia-suspend.service"
              "nvidia-hibernate.service"
            ];
            wantedBy = [
              "systemd-suspend.service"
              "systemd-hibernate.service"
            ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''${pkgs.procps}/bin/pkill -f -STOP ${pkgs.gnome-shell}/bin/gnome-shell'';
            };
          };
          services."gnome-resume" = {
            description = "resume gnome shell";
            after = [
              "systemd-suspend.service"
              "systemd-hibernate.service"
              "nvidia-resume.service"
            ];
            wantedBy = [
              "systemd-suspend.service"
              "systemd-hibernate.service"
            ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = ''${pkgs.procps}/bin/pkill -f -CONT ${pkgs.gnome-shell}/bin/gnome-shell'';
            };
          };
        };
      }
    )
  ];
}

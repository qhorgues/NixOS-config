{ pkgs, lib, config, ... }:

let
  nvidia = config.mx.hardware.gpu.vendor == "nvidia";

  legacy-fermi = config.mx.hardware.gpu.generation ==  "fermi";
  legacy-kepler = config.mx.hardware.gpu.generation == "kelper";
  old-gpu = builtins.elem config.mx.hardware.gpu.generation [  "maxwell" "pascal" ];

  close-nvidia = legacy-fermi || legacy-kepler || old-gpu;

  nvidia580Driver = config.boot.kernelPackages.nvidiaPackages.mkDriver {
    version = "580.142";
    sha256_64bit = "sha256-IJFfzz/+icNVDPk7YKBKKFRTFQ2S4kaOGRGkNiBEdWM=";
    sha256_aarch64 = "sha256-jntr88SpTYR648P1rizQjB/8KleBoa14Ay12vx8XETM=";
    openSha256 = "sha256-v968LbRqy8jB9+yHy9ceP2TDdgyqfDQ6P41NsCoM2AY=";
    settingsSha256 = "sha256-BnrIlj5AvXTfqg/qcBt2OS9bTDDZd3uhf5jqOtTMTQM=";
    persistencedSha256 = "sha256-il403KPFAnDbB+dITnBGljhpsUPjZwmLjGt8iPKuBqw=";
  };
in
{
  config = lib.mkMerge [
    (
      lib.mkIf nvidia {
        hardware.nvidia.package =
          (
            if old-gpu then
            nvidia580Driver
          else if legacy-kepler then
            config.boot.kernelPackages.nvidiaPackages.lecay_470
          else if legacy-fermi then
            config.boot.kernelPackages.nvidiaPackages.lecay_390
          else
            config.boot.kernelPackages.nvidiaPackages.beta
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

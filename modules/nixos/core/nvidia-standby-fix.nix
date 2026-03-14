{ pkgs, lib, config, ... }:

let
  nvidia = config.mx.hardware.gpu.vendor == "nvidia";

  old-gpu = builtins.elem config.mx.hardware.gpu.generation [ "fermi" "kepler" "maxwell" "pascal" ];
in
{
  config = lib.mkMerge [
    (
      lib.mkIf (nvidia && old-gpu) {
        hardware.nvidia.powerManagement.enable = true;
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
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

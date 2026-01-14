{ pkgs, lib, config, ... }:

{
  options.winter.hardware.nvidia.standby = {
    enable = lib.mkEnableOption "Enable Standby fix";
    old-gpu = lib.mkEnableOption "if use gpu before 16 series";
  };

  config = lib.mkMerge [
    (
      lib.mkIf (config.winter.hardware.nvidia.standby.enable && config.winter.hardware.nvidia.standby.old-gpu) {
        hardware.nvidia.powerManagement.enable = true;
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
      }
    )
    (
      lib.mkIf config.winter.hardware.nvidia.standby.enable {

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

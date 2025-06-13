{ pkgs, lib, config, ... }:

{
  options.winter.nvidia.standBy = lib.mkOption {
    description = "Enable Standby fix";
    type = lib.types.bool;
    default = false;
  };

  config = lib.mkIf config.winter.nvidia.standBy {
    hardware.nvidia.powerManagement.enable = true;
    hardware.nvidia.modesetting.enable = true;
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

  };
}

{ config, lib, ... }:
{
  config = lib.mkIf (!config.mx.mode.server.enable) {
    # Automatic mounting device
    services.devmon.enable = true;

    # Virtual filesystems
    services.gvfs.enable = true;

    # Manipulate storage device
    services.udisks2 = {
      enable = true;
    };
  };
}

{ config, lib, ... }:

{
  options = {
    mx.desktop.gnome.enableTrash = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "enable trash support";
    };
  };

  config = lib.mkIf (config.mx.desktop.environment == "gnome" && config.mx.desktop.gnome.enableTrash) {
    environment.sessionVariables.GIO_EXTRA_MODULES = lib.mkForce "${config.services.gvfs.package}/lib/gio/modules";
      environment.variables.GIO_EXTRA_MODULES = lib.mkForce config.environment.sessionVariables.GIO_EXTRA_MODULES;
  };
}

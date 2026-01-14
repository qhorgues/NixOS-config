{ config, lib, ... }:

{
  options = {
    winter.gnome.enableTrash = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "enable trash support";
    };
  };

  config = lib.mkIf (config.winter.gnome.enable && config.winter.gnome.enableTrash) {
    environment.sessionVariables.GIO_EXTRA_MODULES = lib.mkForce "${config.services.gvfs.package}/lib/gio/modules";
      environment.variables.GIO_EXTRA_MODULES = lib.mkForce config.environment.sessionVariables.GIO_EXTRA_MODULES;
  };
}

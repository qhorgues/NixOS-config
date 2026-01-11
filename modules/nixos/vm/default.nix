{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.winter.services.vm;
in {
  options.winter.services.vm = {
    enable = lib.mkEnableOption "Enable Virtual Machine service";
    users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Users for whom virtualization permissions should be enabled.";
    };
  };
  config = lib.mkIf cfg.enable {
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
    virtualisation.spiceUSBRedirection.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu = {
        package = pkgs.qemu_kvm;
        runAsRoot = true;
        swtpm.enable = true;
      };
    };

    users.users = builtins.listToAttrs (map (user: {
      name = user;
      value.extraGroups = [ "kvm" "libvirtd" ];
    }) cfg.users);

    environment.systemPackages = with pkgs; [
      spice
      spice-gtk
      spice-vdagent
    ];
  };
}

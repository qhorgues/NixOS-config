{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.winter.vm;
in {
   config = {
    # boot = {
    #   kernelModules = [
    #     "vfio_pci"
    #     "vfio_iommu_type1"
    #     "vfio"
    #   ];
    #   kernelParams = [
    #     "${cfg.platform}_iommu=on"
    #     ("vfio-pci.ids=" + lib.concatStringsSep "," cfg.vfioIds)
    #   ];
    # };

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

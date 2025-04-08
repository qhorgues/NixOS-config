{ ... }:

let
  nixos-hardware = builtins.fetchTarball https://github.com/NixOS/nixos-hardware/archive/master.tar.gz;
in

{
  imports = [
    (import "${nixos-hardware}/framework/16-inch/7040-amd")
  ];
  
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  fileSystems."/mnt/Games" =
  { device = "/dev/disk/by-uuid/1b35568b-4447-4c80-9880-4b359d4ecb6c";
    fsType = "ext4";
    options = [ "noatime" "nodiratime" "discard" ];
  };
 
}

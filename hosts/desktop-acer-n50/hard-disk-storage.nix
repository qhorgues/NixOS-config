{ config, lib, ... }:
let
  disk     = "/dev/disk/by-uuid/9a0a6005-cd2b-4a34-a391-39ff2afc4f26";
  dataRoot = "/mnt/Data";
  users    = [ "quentin" "elise" ];
  dirs = [ "Bureau" "Téléchargements" "Modèles" "Public" "Documents" "Musique" "Images" "Vidéos" "Projets" ];
in
{
  config = {
    fileSystems = {
      ${dataRoot} = {
        device  = disk;
        fsType  = "ext4";
        options = [ "defaults" "nofail" "x-gvfs-hide" "x-gdu-hide" ];
      };
    } // lib.listToAttrs (lib.flatten (map
      (u: map
        (d: {
          name  = "/home/${u}/${d}";
          value = {
            device  = "${dataRoot}/${u}/${d}";
            fsType  = "none";
            options = [ "bind" "x-gvfs-hide" "x-gdu-hide" ];
          };
        })
        dirs)
      users));

    systemd.tmpfiles.rules = lib.flatten (map
      (u: map (d: "d ${dataRoot}/${u}/${d} 0700 ${u} users -") dirs)
      users);
  };
}

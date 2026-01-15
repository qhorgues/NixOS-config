{ config, lib, ... }:
let
  cfg = config.winter.hardware.ssd;
in
{
  options.winter.hardware.ssd = {
    lists = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of ssd in system";
    };
  };

  config = {
    fileSystems = builtins.listToAttrs (map (disk: {
      name = disk;
      value.options = [ "noatime" "nodiratime" "discard" "defaults" "commit=120" ];
    }) cfg.lists);
  };
}

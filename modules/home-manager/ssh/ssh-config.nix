{ lib, config, ... }:
let
  cfg = config.winter.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {

    programs.ssh = {
      matchBlocks = {
        "repaircafetours" = {
          hostname = "57.128.4.193";
          port = 22;
          user = "quentin";
          identityFile = "~/.ssh/id_ed25519";
        };
        "rpi-quentin-proxy" = {
          hostname = "91.165.146.203";
          port = 48320;
          user = "quentin";
          identityFile = "~/.ssh/id_ed25519";
          proxyJump = "repaircafetours";
          localForwards = [
            {
              bind.port = 11080;
              host.address = "localhost";
              host.port = 32768;
            }
          ];
        };
        "rpi-quentin" = {
          hostname = "91.165.146.203";
          port = 48320;
          user = "quentin";
          identityFile = "~/.ssh/id_ed25519";
          localForwards = [
            {
              bind.port = 10080;
              host.address = "localhost";
              host.port = 32768;
            }
          ];
        };
        "rpi-horgues" = {
          hostname = "91.168.167.51";
          port = 1317;
          user = "quentin";
          identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
  };
}

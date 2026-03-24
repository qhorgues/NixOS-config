{ lib, config, ... }:
let
  cfg = config.mx.programs.ssh;
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
          localForwards = [
            {
              bind.port = 7000;
              host.address = "localhost";
              host.port = 4321;
            }
          ];
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
            {
              bind.port = 11800;
              host.address = "localhost";
              host.port = 8000;
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
          port = 16000;
          user = "quentin";
          identityFile = "~/.ssh/id_ed25519";
        };
        "rpi-horgues-proxy" = {
          hostname = "91.168.167.51";
          port = 16000;
          user = "quentin";
          identityFile = "~/.ssh/id_ed25519";
          proxyJump = "repaircafetours";
          localForwards = [
            {
              bind.port = 5174;
              host.address = "localhost";
              host.port = 5173;
            }
          ];
        };
      };
    };
  };
}

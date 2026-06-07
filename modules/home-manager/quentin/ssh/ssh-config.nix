{ lib, config, ... }:
let
  cfg = config.mx.programs.ssh;
in
{
  config = lib.mkIf cfg.enable {

    programs.ssh = {
      settings = {
        "repaircafetours" = {
          HostName = "57.128.4.193";
          Port = 22;
          User = "quentin";
          IdentityFile = "~/.ssh/id_ed25519";
          LocalForward = [
            {
              bind.port = 7000;
              host.address = "localhost";
              host.port = 4321;
            }
          ];
        };
        "rpi-quentin-proxy" = {
          HostName = "91.165.146.203";
          Port = 48320;
          User = "quentin";
          IdentityFile = "~/.ssh/id_ed25519";
          proxyJump = "repaircafetours";
          LocalForward = [
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
          HostName = "91.165.146.203";
          Port = 48320;
          User = "quentin";
          IdentityFile = "~/.ssh/id_ed25519";
          LocalForward = [
            {
              bind.port = 10080;
              host.address = "localhost";
              host.port = 32768;
            }
          ];
        };
        "rpi-horgues" = {
          HostName = "91.168.167.51";
          Port = 16000;
          User = "quentin";
          IdentityFile = "~/.ssh/id_ed25519";
        };
        "rpi-horgues-proxy" = {
          HostName = "91.168.167.51";
          Port = 16000;
          User = "quentin";
          IdentityFile = "~/.ssh/id_ed25519";
          proxyJump = "repaircafetours";
          LocalForward = [
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

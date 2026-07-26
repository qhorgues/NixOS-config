{ config, lib, pkgs, ... }:

let
  cfg = config.mx.services.wol-relay;

  mkWakeScript = t: pkgs.writeShellScriptBin "wake-${t.name}" ''
    exec ${pkgs.wakeonlan}/bin/wakeonlan -i ${t.broadcastAddress} ${t.mac}
  '';
in
{
  options.mx.services.wol-relay = {
    enable = lib.mkEnableOption ''
      an always-on relay that forwards Wake-on-LAN magic packets onto this LAN
      segment, for a small always-on box (e.g. a Raspberry Pi) that stays reachable
      over its own remote access (SSH here; optionally also Tailscale/WireGuard) so
      it can wake a host that sleeps/powers off and therefore cannot run its own VPN
      endpoint while down (see mx.services.remote-desktop.wakeOnLan and its
      .tailscale / .wireguard backends, which need this kind of relay to be reached
      from outside the LAN).
    '';

    user = lib.mkOption {
      type = lib.types.str;
      default = "wol-relay";
      description = ''
        Unprivileged, key-only account used to trigger the generated
        `wake-<target.name>` commands over SSH.
      '';
    };

    authorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys allowed to log in as `user` and run wake-<target.name>.";
    };

    targets = lib.mkOption {
      default = [ ];
      description = "Hosts this relay can wake with a Wake-on-LAN magic packet.";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption {
            type = lib.types.strMatching "[a-zA-Z0-9_-]+";
            description = "Identifier used for the generated `wake-<name>` command.";
            example = "fw-laptop-16";
          };

          mac = lib.mkOption {
            type = lib.types.strMatching "([0-9A-Fa-f]{2}:){5}[0-9A-Fa-f]{2}";
            description = ''
              MAC address of the target's wired NIC. That NIC must have WoL armed
              (mx.services.remote-desktop.wakeOnLan.interfaces on the target host).
            '';
            example = "AA:BB:CC:DD:EE:FF";
          };

          broadcastAddress = lib.mkOption {
            type = lib.types.str;
            default = "255.255.255.255";
            description = "Broadcast address of the LAN segment the target sits on.";
          };
        };
      });
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.wakeonlan ] ++ map mkWakeScript cfg.targets;

    services.openssh.enable = lib.mkDefault true;

    users.users.${cfg.user} = {
      isNormalUser = true;
      description = "Wake-on-LAN relay account (SSH key only)";
      hashedPassword = "!";
      openssh.authorizedKeys.keys = cfg.authorizedKeys;
    };

    assertions = [
      {
        assertion = cfg.targets != [ ];
        message = "mx.services.wol-relay.enable needs at least one entry in .targets.";
      }
      {
        assertion = cfg.authorizedKeys != [ ];
        message = "mx.services.wol-relay.enable needs at least one entry in .authorizedKeys, else nobody can trigger it remotely.";
      }
      {
        assertion = cfg.user != config.mx.main-user.userName;
        message = "mx.services.wol-relay.user must not be your main user — keep it a minimal, isolated relay account.";
      }
    ];
  };
}

{ config, lib, ... }:

let
  cfg = config.mx.services.remote-desktop.wakeOnLan;
in
{
  options.mx.services.remote-desktop.wakeOnLan = {
    enable = lib.mkEnableOption "Wake-on-LAN (magic packet) on the listed interfaces";

    interfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      example = [ "enp0s13f0u1" ];
      description = ''
        Wired interfaces armed for Wake-on-LAN magic packets (ethtool `wol g`).
        Names are host-specific — list them with `ip link`.

        Caveats:
          - Laptop WoL usually needs a wired Ethernet link, a STABLE MAC, and a
            BIOS "Wake on LAN / power-on by PCIe" option. Many laptops only wake
            from suspend (S3), not full shutdown (S5). Wi-Fi WoWLAN is unreliable.
          - Incompatible with `mx.core.network.security-mode`, which randomizes the
            Ethernet MAC (see modules/nixos/core/network.nix): a rotating MAC gives
            the magic packet no fixed target.
          - The magic packet is layer 2, so a remote sender needs a relay already on
            this LAN (e.g. a Tailscale node — see ./tailscale.nix).
      '';
    };
  };

  config = lib.mkIf (config.mx.services.remote-desktop.enable && cfg.enable) {
    # Reuse the upstream ethtool oneshot; it re-arms the NIC whenever the device
    # (re)appears, so WoL survives reboots and link changes.
    networking.interfaces = lib.genAttrs cfg.interfaces (_: {
      wakeOnLan.enable = true;
    });

    assertions = [
      {
        assertion = cfg.interfaces != [ ];
        message = "mx.services.remote-desktop.wakeOnLan.enable needs at least one entry in .interfaces.";
      }
    ];
  };
}

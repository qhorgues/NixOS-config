{ config, lib, ... }:

let
  rd = config.mx.services.remote-desktop;
  cfg = rd.wireguard;

  # networking.wireguard peer, dropping the optional fields left at null.
  mkPeer = p:
    { inherit (p) publicKey allowedIPs; }
    // lib.optionalAttrs (p.presharedKeyFile != null) { inherit (p) presharedKeyFile; }
    // lib.optionalAttrs (p.endpoint != null) { inherit (p) endpoint; }
    // lib.optionalAttrs (p.persistentKeepalive != null) { inherit (p) persistentKeepalive; };
in
{
  options.mx.services.remote-desktop.wireguard = {
    enable = lib.mkEnableOption ''
      a self-hosted WireGuard tunnel to reach Sunshine from anywhere, as an
      alternative to Tailscale (no third-party coordination server). Sunshine is
      reachable over the tunnel interface, which is trusted; the handshake port is
      opened to the WAN. Mutually exclusive with ./tailscale.nix. A peer already on
      this LAN can also relay the Wake-on-LAN magic packet (see ./wake-on-lan.nix)
    '';

    exposeOnLan = lib.mkEnableOption ''
      also open the Sunshine ports on the local network. Off by default: Sunshine
      is reachable only over the WireGuard interface (which is trusted), keeping the
      stream off the raw LAN/WAN.
    '';

    interface = lib.mkOption {
      type = lib.types.str;
      default = "wg0";
      description = "Name of the WireGuard interface created for the tunnel.";
    };

    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 51820;
      description = ''
        UDP port WireGuard listens on for the handshake. Opened in the firewall
        and, for external access, must be forwarded to this host on the router.
      '';
    };

    address = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "10.100.0.1/24" ];
      example = [ "10.100.0.1/24" ];
      description = "This host's address(es) inside the tunnel (IP/CIDR).";
    };

    privateKeyFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets/fw-laptop-16/wireguard-key.age;
      description = ''
        agenix-encrypted WireGuard private key (from `wg genkey`). The default is
        host-specific (fw-laptop-16); override on other hosts. Decrypted at
        activation with the host SSH key.
      '';
    };

    peers = lib.mkOption {
      default = [ ];
      description = "Client peers allowed to connect to this WireGuard server.";
      type = lib.types.listOf (lib.types.submodule {
        options = {
          publicKey = lib.mkOption {
            type = lib.types.str;
            description = "The peer's WireGuard public key.";
          };

          allowedIPs = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            example = [ "10.100.0.2/32" ];
            description = "Tunnel IPs routed to this peer (usually its /32).";
          };

          presharedKeyFile = lib.mkOption {
            type = lib.types.nullOr lib.types.path;
            default = null;
            description = "Optional agenix-encrypted preshared key for this peer.";
          };

          endpoint = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "peer.example.com:51820";
            description = "Optional fixed endpoint for a peer with a stable address.";
          };

          persistentKeepalive = lib.mkOption {
            type = lib.types.nullOr lib.types.int;
            default = null;
            example = 25;
            description = "Optional keepalive interval (seconds) to hold NAT open.";
          };
        };
      });
    };
  };

  config = lib.mkIf (rd.enable && cfg.enable) {
    # Declared only when this backend is enabled, so other hosts need not ship the
    # secret. Decrypts to /run/agenix/remote-desktop-wireguard (root, 0400).
    age.secrets.remote-desktop-wireguard.file = cfg.privateKeyFile;

    networking.wireguard.interfaces.${cfg.interface} = {
      ips = cfg.address;
      inherit (cfg) listenPort;
      privateKeyFile = config.age.secrets.remote-desktop-wireguard.path;
      peers = map mkPeer cfg.peers;
    };

    # Handshake reachable from the WAN (router must also forward this port).
    networking.firewall.allowedUDPPorts = [ cfg.listenPort ];

    # Trust the tunnel; Sunshine's ports are then reachable over it without
    # punching them into the LAN/WAN firewall (mirrors ./tailscale.nix).
    networking.firewall.trustedInterfaces = [ cfg.interface ];

    # Override the module default (see ./default.nix): keep Sunshine off the LAN
    # unless explicitly asked. mkForce wins over the mkDefault there.
    services.sunshine.openFirewall = lib.mkForce cfg.exposeOnLan;

    assertions = [
      {
        assertion = !rd.tailscale.enable;
        message = "mx.services.remote-desktop: choose either tailscale OR wireguard, not both (both force services.sunshine.openFirewall and trust their own VPN interface).";
      }
      {
        assertion = cfg.peers != [ ];
        message = "mx.services.remote-desktop.wireguard.enable needs at least one entry in .peers.";
      }
    ];
  };
}

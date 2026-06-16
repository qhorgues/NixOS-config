{ lib, config, ... }:
let
  cfg = config.mx.core.networking.dnsmasq;
in
{
  options.mx.core.networking.dnsmasq = {
    nonPrivate = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Restrict accès for non-private DNS";
    };
  };
  config = {
    services.dnsmasq = {
      enable = true;
      settings = {
        listen-address = "127.0.0.1";
        cache-size = 1000;
        no-resolv = true;

        server = [
          "9.9.9.9"         # Quad9
          "149.112.112.112" # Quad9
          "194.242.2.2"     # Mullvad
          "194.242.2.3"     # Mullvad
          "94.140.14.14"    # AdGuard
          "94.140.15.15"    # AdGuard
          "80.67.169.12"    # FDN
          "80.67.169.40"    # FDN
          "193.110.81.0"    # DNS0.eu
          "185.253.5.0"     # DNS0.eu
          "194.150.168.168" # Freifunk
        ]
        ++ (lib.optionals (!cfg.nonPrivate) [
          "208.67.222.222"  # OpenDNS
          "208.67.220.220"  # OpenDNS
          "1.1.1.1"         # Cloudflare
          "1.0.0.1"         # Cloudflare
          "8.8.8.8"         # Google
          "8.8.4.4"         # Google
        ]);
      };
    };
    networking.networkmanager.dns = "dnsmasq";
  };
}

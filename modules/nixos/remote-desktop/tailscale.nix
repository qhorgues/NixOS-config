{ config, lib, ... }:

let
  cfg = config.mx.services.remote-desktop.tailscale;
in
{
  options.mx.services.remote-desktop.tailscale = {
    enable = lib.mkEnableOption ''
      Tailscale to reach Sunshine from anywhere and to relay Wake-on-LAN.
      NAT traversal removes the need for port forwarding; another tailnet node on
      this LAN can emit the WoL magic packet. First run is manual: `tailscale up`.
    '';

    exposeOnLan = lib.mkEnableOption ''
      also open the Sunshine ports on the local network. Off by default: Sunshine
      is reachable only over the tailnet (tailscale0 is trusted), keeping the
      stream off the raw LAN/WAN.
    '';
  };

  config = lib.mkIf (config.mx.services.remote-desktop.enable && cfg.enable) {
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client";
      openFirewall = true; # UDP 41641 for Tailscale itself
    };

    # Trust the tailnet; Sunshine's ports are then reachable over tailscale0
    # without punching them into the LAN/WAN firewall.
    networking.firewall.trustedInterfaces = [ "tailscale0" ];

    # Override the module default (see ./default.nix): keep Sunshine off the LAN
    # unless explicitly asked. mkForce wins over the mkDefault there.
    services.sunshine.openFirewall = lib.mkForce cfg.exposeOnLan;
  };
}

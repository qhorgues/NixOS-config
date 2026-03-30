{ pkgs, lib, inputs, ... }:
{
  environment.systemPackages = [
    inputs.agenix.packages."${pkgs.stdenv.hostPlatform.system}".default
  ];

  services.openssh = {
    enable = true;
    openFirewall = lib.mkDefault false;
  };
}

{ config, inputs, pkgs, lib }:
let
  cfg = config.mx.services.home-manager;
in
{
  options.mx.services.home-manager = {
    enable = lib.mkEnableOption "Enable home-manager";
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        firefox-addons = inputs.firefox-addons;
      };
    };

    environment.systemPackages = with pkgs; [
      home-manager
    ];
  };
}

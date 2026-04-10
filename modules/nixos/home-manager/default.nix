{ config, inputs, pkgs, pkgs-unstable, lib, self, ... }:
let
  cfg = config.mx.programs.home-manager;
in
{
  options.mx.programs.home-manager = {
    enable = lib.mkEnableOption "Enable home-manager";
    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          configPath = lib.mkOption {
            type = lib.types.path;
            description = "Path to the Home Manager configuration file";
          };
          homeModule = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Name of the home module in self.homeModules";
          };
        };
      });
      default = {};
      description = "Map of users to their Home Manager configuration";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        qhorgues-config = self;
        modulix-os-pkgs-unstable = import inputs.nixpkgs-unstable {
          system = pkgs.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
        inputs-modulix-os = inputs;
        pkgs-unstable = pkgs-unstable;
      };
      users = lib.mapAttrs (username: userCfg: {
        imports = [
          userCfg.configPath
        ] ++ lib.optional (userCfg.homeModule != null) self.homeModules.${userCfg.homeModule};
        home.username = lib.mkDefault username;
        home.homeDirectory = lib.mkDefault "/home/${username}";
      }) cfg.users;
    };
  };
}

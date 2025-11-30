{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
        url = "github:nix-community/home-manager/release-25.11";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    firefox-addons = {
        url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    winapps = {
        url = "github:winapps-org/winapps";
        inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    nixpkgsConfig = {
      allowUnfree = true;
    };
  in
  {
    nixosConfigurations =
    {
      "fw-laptop-16" = let
        system = "x86_64-linux";
      in nixpkgs.lib.nixosSystem
      {
        system = system;
        specialArgs = { inherit self inputs;
            winapps = inputs.winapps.packages.${system};
            pkgs-unstable = import nixpkgs-unstable {
              system = system;
              config = nixpkgsConfig;
            };
        };
        modules = [
          ./hosts/fw-laptop-16/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      "unowhy-13" = let
        system = "x86_64-linux";
      in nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = { inherit self inputs;
            winapps = inputs.winapps.packages.${system};
            pkgs-unstable = import nixpkgs-unstable {
                system = system;
                config = nixpkgsConfig;
            };
        };
        modules = [
            ./hosts/unowhy-13/configuration.nix
            inputs.home-manager.nixosModules.default
        ];
      };
      "desktop-acer-n50" = let
        system = "x86_64-linux";
      in nixpkgs.lib.nixosSystem {
       	system = system;
       	specialArgs = { inherit self inputs;
            winapps = inputs.winapps.packages.${system};
            pkgs-unstable = import nixpkgs-unstable {
                system = system;
                config = nixpkgsConfig;
            };
        };
       	modules = [
            ./hosts/desktop-acer-n50/configuration.nix
            inputs.home-manager.nixosModules.default
       	];
      };
    };
  };
}

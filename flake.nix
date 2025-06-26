{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, ... }@inputs:
  let
    system = "x86_64-linux";
    nixpkgsConfig = {
      allowUnfree = true;
    };
    pkgs = nixpkgs.legacyPackages.${system};
    pkgs-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config = nixpkgsConfig;
    };
  in
  {
    nixosConfigurations = {
      "fw-laptop-16" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/fw-laptop-16.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      "unowhy-13" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/unowhy-13.nix
        ];
      };
      "desktop-acer-n50" = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	specialArgs = { inherit inputs; };
	modules = [
	  ./hosts/desktop-acer-n50.nix
	];
      };
    };

    homeConfigurations = {
      "quentin" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./users/quentin/home.nix
        ];
        extraSpecialArgs = { inherit system pkgs-unstable self; };
      };
    };
  };
}

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, unstable }@inputs:
  {
    nixosConfigurations = {
      "fw-laptop-quentin" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs unstable; };
        modules = [
          ./hosts/fw-laptop-quentin.nix
        ];
      };
    };

    homeConfigurations = {
      "quentin" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./users/quentin/home.nix
          ./users/quentin/shell.nix
          ./users/quentin/git.nix
          ./users/quentin/gnome.nix
        ];
        extraSpecialArgs = { inherit nixpkgs unstable; };
      };
    };
  };
}

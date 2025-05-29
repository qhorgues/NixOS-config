{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager }@inputs:
  let
    system = "x86_64-linux";
    nixpkgsConfig = {
      allowUnfree = true;
    };
    # Utilisation de nixpkgsConfig pour la cohérence
    pkgsStable = import nixpkgs {
      inherit system;
      config = nixpkgsConfig;
    };

    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config = nixpkgsConfig;
    };
    pkgs-unstable = pkgsUnstable;
  in
  {
    nixosConfigurations = {
      "fw-laptop-16" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit system pkgs-unstable; };
        modules = [
          ./hosts/fw-laptop-16.nix
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
        extraSpecialArgs = { inherit system pkgs-unstable; };
      };
    };
  };
}

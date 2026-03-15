{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
        url = "github:nix-community/home-manager/release-25.11";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    firefox-addons = {
        url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
        inputs.nixpkgs.follows = "nixpkgs";
    };
    coe33 = {
      url = "github:qhorgues/CO-E33-Save-Editor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, coe33, ... }@inputs:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in
  {
    nixosModules.modulix-os = ./modules/nixos/default.nix;

    homeModules.quentin = ./modules/home-manager/quentin/default.nix;

    packages = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        coe33 = coe33.packages.${system}.default;
        clean-dir = import ./pkgs/clean-dir.nix { inherit pkgs; };
        lsfg-vk = pkgs.callPackage ./pkgs/lsfg-vk.nix {};
        nix-clean = import ./pkgs/nix-clean.nix { inherit pkgs; };
        nix-latest-update = import ./pkgs/nix-latest-update.nix { inherit pkgs; };
      }
    );
  };
}

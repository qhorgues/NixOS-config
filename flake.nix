{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
    nix-cachyos-kernel.url = "github:xddxdd/nix-cachyos-kernel/release";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, coe33, ... }@inputs:
  let
    systems = [ "x86_64-linux" "aarch64-linux" "i686-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = nixpkgs.lib.genAttrs systems;

    nixpkgsConfig = {
      allowUnfree = true;
    };

    make-system = {
        system ? "x86_64-linux",
        modules ? [],
        specialArgs ? {},
      }:
      let
        pkgs-unstable = import nixpkgs-unstable {
          system = system;
          config = nixpkgsConfig;
        };
        defaults = {
          inherit self pkgs-unstable inputs;
          secretsPath = ./secrets;
        };
      in nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = defaults // specialArgs;
        modules = [
          inputs.agenix.nixosModules.default
          inputs.home-manager.nixosModules.default
          ./modules/nixos
        ] ++ modules;
      };
  in
  {
    lib.make-system = make-system;
    nixosModules = {
      modulix-os =
        { ... }: {
          imports = [ ./modules/nixos ];
          _module.args = {
            inputs = inputs;
            secretsPath = ./secrets;
          };
        };
      home-manager = inputs.home-manager.nixosModules.default;
      agenix = inputs.agenix.nixosModules.default;
    };
    homeModules.quentin = ./modules/home-manager/quentin;

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
        kiwix = pkgs.callPackage ./pkgs/kiwix.nix { inherit pkgs; };
      }
    );
  };
}

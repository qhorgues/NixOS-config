{
  description = "NixOS hosts and Home Manager profile";

  inputs = {
    mxpkgs.url = "github:Modulix-OS/mxpkgs";
    nixpkgs.follows = "mxpkgs/nixpkgs";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    mxpkgs.inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    coe33 = {
      url = "github:qhorgues/CO-E33-Save-Editor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { mxpkgs, agenix, nixos-hardware, coe33, ... }:
  let
    mkHost = name: mxpkgs.lib.modulixosSystem {
      system = "x86_64-linux";
      modules = [
        agenix.nixosModules.default
        ./hosts/common.nix
        ./hosts/${name}/configuration.nix
      ];
      specialArgs = {
        inherit nixos-hardware agenix coe33;
        secretsPath = ./secrets;
      };
    };
  in
  {
    nixosConfigurations = {
      fw-laptop-16 = mkHost "fw-laptop-16";
      desktop-acer-n50 = mkHost "desktop-acer-n50";
    };
  };
}

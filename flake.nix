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
    common = { pkgs, lib, ... }: {
      nixpkgs.overlays = [
        (final: prev: {
          coe33 = coe33.packages.${prev.stdenv.hostPlatform.system}.default;
        })
      ];

      # agenix decrypts with the host SSH key.
      age.identityPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
      environment.systemPackages = [
        agenix.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      services.openssh = {
        enable = true;
        openFirewall = lib.mkDefault false;
      };
    };

    mkHost = name: mxpkgs.lib.modulixosSystem {
      system = "x86_64-linux";
      modules = [
        agenix.nixosModules.default
        common
        ./hosts/${name}/configuration.nix
      ];
      specialArgs = {
        inherit nixos-hardware;
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

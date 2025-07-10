{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons"; inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }@inputs:
  let
    system = "x86_64-linux";
    nixpkgsConfig = {
      allowUnfree = true;
    };
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config = nixpkgsConfig;
    };
    calculationModule_php = builtins.fetchGit {
      url = "ssh://git@codeberg.org/GestionBudget/CppLayerPHP.git";
      ref = "main";
      rev = "01590c03e0d4bba295f4bca80c88d716082d12df";
      allRefs = true;
      submodules = true;
    };
  in
  {
    nixosConfigurations =
    {
      "fw-laptop-16" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self inputs pkgs-unstable calculationModule_php; };
        modules = [
          ./hosts/fw-laptop-16/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      "unowhy-13" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit self inputs pkgs-unstable; };
        modules = [
          ./hosts/unowhy-13/configuration.nix
          inputs.home-manager.nixosModules.default
        ];
      };
      "desktop-acer-n50" = nixpkgs.lib.nixosSystem {
       	system = "x86_64-linux";
       	specialArgs = { inherit self inputs pkgs-unstable calculationModule_php; };
       	modules = [
       	  ./hosts/desktop-acer-n50/configuration.nix
          inputs.home-manager.nixosModules.default
       	];
      };
    };
  };
}

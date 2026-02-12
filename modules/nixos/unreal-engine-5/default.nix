
{ pkgs, config, lib, ... }:

let
  cfg = config.winter.programs.unreal-engine-5;
in
{
  options.winter.programs.unreal-engine-5 = {
    enable = lib.mkEnableOption "Enable unreal setup";
  };

  config = lib.mkIf cfg.enable {
    # Activer les paquets non-libres si nécessaire
    nixpkgs.config.allowUnfree = true;

    # Configuration graphique (noms mis à jour)
    hardware.graphics.enable = true;
    hardware.graphics.enable32Bit = true;  # Support 32-bit

    # Support Vulkan
    hardware.graphics.extraPackages = with pkgs; [
      vulkan-loader
      vulkan-validation-layers
    ];

    # Ajouter l'environnement FHS pour Unreal Engine
    environment.systemPackages = with pkgs; [
      (pkgs.callPackage ../../../pkgs/unreal-engine-5-fhs.nix {})

      # Autres dépendances utiles
      vulkan-tools
      mesa-demos
    ];
  };
}

{ lib, ... }:
with lib;
{
  options.winter.vm = {
    users = mkOption {
      type = with types; listOf str;
      default = [];
      description = "Utilisateurs pour lesquels activer les permissions liées à la virtualisation.";
    };

    # platform = mkOption {
    #   type = types.str;
    #   default = "";
    #   description = "Plateforme CPU (ex: amd ou intel) pour configurer les options IOMMU.";
    # };

    # vfioIds = mkOption {
    #   type = with types; listOf str;
    #   default = [];
    #   description = "Liste des identifiants PCI des périphériques à passer via VFIO.";
    # };
  };
}

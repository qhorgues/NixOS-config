{ pkgs, calculationModule_php, ... }:

let
    calculationModule = import calculationModule_php { inherit pkgs; };
in
{
    environment.systemPackages = [
        calculationModule
    ];

    # Pour charger l’extension PHP
    services.phpfpm.phpOptions = ''
      extension=${calculationModule}
    '';
}

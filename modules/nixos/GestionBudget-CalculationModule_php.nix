{ pkgs, inputs, ... }:
{}
# let
#     calculationModule = import inputs.calculationModule_php { inherit pkgs; };
# in
# {
#     environment.systemPackages = [
#         calculationModule
#     ];
#
#     # Pour charger l’extension PHP
#     services.phpfpm.phpOptions = ''
#       extension=${calculationModule}
#     '';
# }

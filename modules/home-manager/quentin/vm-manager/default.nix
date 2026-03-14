{ pkgs, lib, osConfig, config, ... }:
{
  config = lib.mkIf (osConfig.mx.services.vm.enable && lib.elem config.home.username osConfig.mx.services.vm.users) {
  	home.packages = with pkgs; [
   		virt-manager
  	];
  };
}

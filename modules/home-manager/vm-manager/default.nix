{ pkgs, lib, osConfig, config, ... }:
{
  config = lib.mkIf (osConfig.winter.services.vm.enable && lib.elem config.home.username osConfig.winter.services.vm.users) {
  	home.packages = with pkgs; [
   		virt-manager
  	];
  };
}

{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.teamviewer ];
  services.teamviewer.enable = true;
}

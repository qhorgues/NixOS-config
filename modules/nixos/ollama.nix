{ config, pkgs, lib, ... }:

let
  open-webui-shortcut = pkgs.makeDesktopItem {
    name = "Open WebUI";
    desktopName = "IA local";
    exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:8080"; # Commande pour exécuter l'application
    icon = "wechat"; # Chemin vers l'icône
    comment = "Acceder a l'ia locale";
    categories = [ "Utility" ];
  };
in
{
  config = {
    winter.hardware.gpu.enable-acceleration = true;

    environment.systemPackages = [
      pkgs.ollama
      open-webui-shortcut
      # pkgs-unstable.newelle
    ];


    services.open-webui = {
      package = pkgs.open-webui;
      enable = true;
      port = 8080;
    };

    services.ollama = {
      enable = true;
      loadModels = [ "gemma3:4b" ];
      acceleration = config.winter.hardware.gpu.acceleration; # use cuda if nvidia, rocm if amd, and cpu only otherwise
    };
  };
}

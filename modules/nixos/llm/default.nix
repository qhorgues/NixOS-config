{ config, pkgs, pkgs-unstable,  lib, ... }:

let
  cfg = config.mx.services.llm;
  # open-webui-shortcut = pkgs.makeDesktopItem {
  #   name = "Open WebUI";
  #   desktopName = "IA local";
  #   exec = "${pkgs.xdg-utils}/bin/xdg-open http://localhost:8080";
  #   icon = "wechat";
  #   comment = "Acceder a l'ia locale";
  #   categories = [ "Utility" ];
  # };
in
{
  options.mx.services.llm = {
    enable = lib.mkEnableOption "Enable local LLM service";
    open-webui = {
      enable = lib.mkEnableOption "Enable Open Webui service";
      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for open webui interface";
      };
    };
  };
  config = lib.mkIf cfg.enable {
    mx.hardware.gpu.enable-computing = true;

    environment.systemPackages = [
      # open-webui-shortcut
      pkgs-unstable.newelle
    ];


    services.open-webui = {
      package = pkgs-unstable.open-webui;
      enable = cfg.open-webui.enable;
      port = cfg.open-webui.port;
    };

    services.ollama = {
      enable = true;
      package =
      (if config.mx.hardware.gpu.computing == "cuda" then
        pkgs.ollama-cuda
      else if config.mx.hardware.gpu.computing == "rocm" then
        pkgs.ollama-rocm
      else if config.mx.hardware.gpu.computing == "intel" then
        pkgs.ollama-vulkan
      else if config.mx.hardware.gpu.computing == "cpu" then
        pkgs.ollama-cpu
      else
        pkgs.ollama
      );
      loadModels = [
        "gemma4:e4b"
        "qwen2.5-coder:7b"
        "qwen3.5:9b"
      ];
    };
  };
}

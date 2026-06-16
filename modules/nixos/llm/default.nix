{ config, pkgs, pkgs-unstable, lib, ... }:
let
  cfg = config.mx.services.llm;

  llamaCppPackage =
    let
      base = pkgs-unstable.llama-cpp;
      computing = config.mx.hardware.gpu.computing;
    in
      if computing == "cuda" then
        base.override { cudaSupport = true; }
      else if computing == "rocm" then
        pkgs-unstable.pkgsRocm.llama-cpp
      else if computing == "intel" then
        base.override { vulkanSupport = true; }
      else
        base;

  modelOptions = lib.types.submodule {
    options = {
      hf-repo = lib.mkOption { type = lib.types.str; description = "HuggingFace repo"; };
      hf-file = lib.mkOption { type = lib.types.str; description = "GGUF filename"; };
      alias = lib.mkOption { type = lib.types.str; description = "Model alias"; };
      ctx-size = lib.mkOption { type = lib.types.str; default = "8192"; };
      temp = lib.mkOption { type = lib.types.str; default = "0.7"; };
      top-p = lib.mkOption { type = lib.types.str; default = "0.95"; };
      min-p = lib.mkOption { type = lib.types.str; default = "0.01"; };
      top-k = lib.mkOption { type = lib.types.str; default = "40"; };
      jinja = lib.mkOption { type = lib.types.str; default = "on"; };
      load-on-startup = lib.mkOption { type = lib.types.str; default = "false"; };
      stop-timeout = lib.mkOption { type = lib.types.str; default = "60"; };
    };
  };
in
{
  options.mx.services.llm = {
    enable = lib.mkEnableOption "Enable local LLM service";

    host = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Bind address for llama-cpp server";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8081;
      description = "Port for llama-cpp server";
    };

    extraFlags = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "-ngl" "99" "--parallel" "4" "-fa" "on" ];
      description = "Extra flags passed to llama-cpp";
    };

    modelsPreset = lib.mkOption {
      type = lib.types.attrsOf modelOptions;
      default = { };
      description = "Model presets for llama-cpp";
    };

    huggingfaceTokenFile = lib.mkOption {
      type = lib.types.path;
      default = ../../../secrets/shared/huggingface-token.age;
      description = "Path to agenix-encrypted HuggingFace token";
    };

    enableNewelle = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install Newelle GUI client";
    };

    open-webui = {
      enable = lib.mkEnableOption "Enable Open Webui service";

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.open-webui;
        description = "Open WebUI package to use";
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 8080;
        description = "Port for open webui interface";
      };

      extraEnvironment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        description = "Extra environment variables for Open WebUI";
      };
    };

    llamaCppPackage = lib.mkOption {
      type = lib.types.package;
      default = llamaCppPackage;
      description = "llama-cpp package to use (auto-selected by GPU backend)";
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.huggingface-token.file = cfg.huggingfaceTokenFile;

    mx.hardware.gpu.enable-computing = true;

    environment.systemPackages = lib.mkIf cfg.enableNewelle [
      pkgs-unstable.newelle
    ];

    services.open-webui = {
      package = cfg.open-webui.package;
      enable = cfg.open-webui.enable;
      port = cfg.open-webui.port;
      environment = {
        OLLAMA_BASE_URL = "";
        OPENAI_API_BASE_URL = "http://${cfg.host}:${toString cfg.port}/v1";
        OPENAI_API_KEY = "none";
      } // cfg.open-webui.extraEnvironment;
    };

    services.llama-cpp = {
      enable = true;
      package = cfg.llamaCppPackage;
      host = cfg.host;
      port = cfg.port;
      extraFlags = cfg.extraFlags;
      modelsPreset = cfg.modelsPreset;
    };

    systemd.services.llama-cpp = {
      serviceConfig = {
        EnvironmentFile = config.age.secrets.huggingface-token.path;
      };
    };
  };
}

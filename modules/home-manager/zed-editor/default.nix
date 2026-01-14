{ pkgs, lib, config, osConfig, ... }:

let
  cfg = config.winter.programs.zed-editor;
in
{
  options.winter.programs.zed-editor = {
    enable = lib.mkEnableOption "Use Zed Editor";
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      package = pkgs.zed-editor;
      extensions = ["html" "toml" "make" "neocmake"];

      userSettings = {
        language_models = {
            ollama = lib.mkIf osConfig.winter.services.llm.enable {
                api_url = "http://localhost:11434";
                available_models = [
                    {
                        name = "gemma3:4b";
                        display_name = "gemma3:4b";
                        max_tokens = 32768;
                        supports_tools = true;
                    }
                ];
            };
        };
        edit_predictions = {
            enabled_in_text_threads = true;
        };
        auto_update = true;
        telemetry = {
            diagnostics = false;
            metrics = false;
        };
        terminal = {
        alternate_scroll = "off";
        blinking = "off";
        copy_on_select = false;
        dock = "bottom";
        detect_venv = {
            on = {
            directories = [".env" "env" ".venv" "venv"];
            activate_script = "default";
            };
        };
        env = {
            TERM = "alacritty";
        };
        font_features = null;
        font_size = null;
        line_height = "comfortable";
        option_as_meta = false;
        button = false;
        shell = "system";
        toolbar = {
            breadcrumbs = false;
        };
        scrollbar = {
            show = "never";
        };
        working_directory = "current_project_directory";
        };
        languages = {
          "C++" = {
              format_on_save = "on";
              tab_size = 4;
          };
          "Python" = {
              language_servers = [ "ruff" "pyright" ];
              format_on_save = "on";
              formatter = [

              ];
          };
          "Nix" = {
              language_servers = [ "nixd" ];
              formatter = [
                  "prettier"
              ];
              format_on_save = "on";
          };
        };
        lsp = {
          clangd = {
              binary = {
                  path = "${pkgs.clang-tools}/bin/clangd";
                  arguments = [
                      "--compile-commands-dir=build"
                  ];
              };
          };
          pyright = {
              settings = {
              python.analysis = {
                  diagnosticMode = "workspace";
                  typeCheckingMode = "strict";
              };
              python = {
                  pythonPath = ".venv/bin/python";
              };
              };
          };
          rust-analyzer = {
              binary = {
                  path = lib.getExe pkgs.rust-analyzer;
              };
          };
          nix = {
              enable_lsp_tasks = true;
          };
        };


        ## tell zed to use direnv and direnv can use a flake.nix enviroment.
        load_direnv = "shell_hook";
        base_keymap = "VSCode";
        theme = {
            mode = "system";
            light = "One Light";
            dark = "One Dark";
        };
        show_whitespaces = "none" ;
        ui_font_size = 16;
        buffer_font_size = 14;
        diagnostics.include_warnings = true;
        collaboration_panel.button = true;
        chat_panel.button = "when_in_call";
        show_wrap_guides = false;
        tab_bar.show = false;
        debugger.dock = "left";
        soft_wrap = "bounded";
        notification_panel.button = false;
        autosave = "on_focus_change";

        calls = {
          mute_on_join = true;
          share_on_join = true;
        };
      };
    };
  };
}

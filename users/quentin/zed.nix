{pkgs, lib, ... }:

{
  programs.zed-editor = {
    #  enable = true;
    extensions = ["html" "toml" "elixir" "make" "neocmake"];

    userSettings = {
    assistant = {
    enabled = true;
    version = "2";
    default_open_ai_model = null;
    ### PROVIDER OPTIONS
    ### zed.dev models { claude-3-5-sonnet-latest } requires github connected
    ### anthropic models { claude-3-5-sonnet-latest claude-3-haiku-latest claude-3-opus-latest  } requires API_KEY
    ### copilot_chat models { gpt-4o gpt-4 gpt-3.5-turbo o1-preview } requires github connected
    default_model = {
        provider = "zed.dev";
        model = "claude-3-5-sonnet-latest";
    };

    # inline_alternatives = [
    #     {
    #         provider = "copilot_chat";
    #         model = "gpt-3.5-turbo";
    #     }
    # ];
    };
    hour_format = "hour24";
    auto_update = true;
    telemetry.enable = false;
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
    font_family = "FiraCode Nerd Font";
    font_features = null;
    font_size = null;
    line_height = "comfortable";
    option_as_meta = false;
    button = false;
    shell = "system";
    #{
    #                    program = "zsh";
    #};
    toolbar = {
        title = true;
    };
    working_directory = "current_project_directory";
    };
    languages = {
    "Python" = {
        language_servers = [ "ruff" "pyright" ];
        format_on_save = true;
        formatter = [

        ];
    };
    "Nix" = {
        language_servers = [ "nil" ];
        format_on_save = true;
    };
    };
    lsp = {
      clangd = {
        binary.arguments = [ "--compile-commands-dir=build" ];
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
          path_lookup = true;
        };
      };
      nix = {
        binary = {
          path_lookup = true;
        };
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
    show_whitespaces = "all" ;
    ui_font_size = 12;
    buffer_font_size = 12;
    diagnostics.include_warnings = true;
    collaboration_panel.button = true;
    chat_panel.button = "when_in_call";
    show_wrap_guides = false;
    tab_bar.show = false;
    edit_prediction.enabled = false;
    soft_wrap = "bounded";
    soft_wrap_column = 80;
    notification_panel.button = false;
    autosave = "on_focus_change";

    };
  };
}

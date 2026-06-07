{ pkgs-unstable, lib, config, osConfig, ... }:

let
  cfg = config.mx.programs.zed-editor;
in
{
  options.mx.programs.zed-editor = {
    enable = lib.mkEnableOption "Use Zed Editor";
  };
  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      installRemoteServer = true;
      package = pkgs-unstable.zed-editor;
      extensions = ["html" "toml" "make" "neocmake"];

      userSettings = {
        disable_ai = false;
        window_decorations = "client";
        use_system_window_tabs = false;
        bottom_dock_layout = "contained";
        preview_tabs = {
          enable_preview_from_project_panel = true;
          enabled = true;
        };
        tabs = {
          file_icons = false;
          git_status = false;
        };
        title_bar = {
          button_layout = "platform_default";
          show_menus = false;
          show_user_picture = true;
          show_user_menu = true;
          show_sign_in = true;
          show_project_items = true;
          show_branch_name = true;
        };
        search = {
          button = false;
        };
        status_bar = {
          show_active_file = false;
          cursor_position_button = true;
          active_encoding_button = "non_utf8";
          active_language_button = true;
        };
        colorize_brackets = true;
        inlay_hints = {
          enabled = false;
        };
        toolbar = {
          code_actions = false;
          agent_review = true;
          selections_menu = true;
          quick_actions = true;
          breadcrumbs = true;
        };
        minimap = {
          show = "never";
        };
        diff_view_style = "unified";
        cli_default_open_behavior = "existing_window";
        project_panel = {
          hide_root = true;
          hide_hidden = false;
          diagnostic_badges = true;
          git_status_indicator = true;
          button = true;
          dock = "left";
        };
        outline_panel = {
          button = false;
          dock = "left";
        };
        auto_indent_on_paste = true;
        auto_indent = "preserve_indent";
        icon_theme = "Zed (Default)";
        format_on_save = "on";
        git_panel = {
          show_count_badge = true;
          button = true;
          dock = "left";
          tree_view = false;
        };
        agent = {
          sidebar_side = "right";
          limit_content_width = true;
          flexible = true;
          button = true;
          dock = "right";
          default_model = {
            provider = "ollama";
            model = "qwen3.5:9b";
          };
          inline_assistant_model = {
            provider = "ollama";
            model = "qwen2.5-coder:7b";
          };
          model_parameters = [];
        };
        auto_install_extensions = {
          html = true;
          make = true;
          neocmake = true;
          toml = true;
        };
        auto_update = true;
        autosave = "on_focus_change";
        base_keymap = "VSCode";
        buffer_font_size = 14;
        calls = {
          mute_on_join = true;
          share_on_join = true;
        };
        collaboration_panel = {
          dock = "left";
          button = true;
        };
        debugger = {
          dock = "left";
        };
        diagnostics = {
          button = true;
          include_warnings = true;
        };
        edit_predictions = {
          provider = "zed";
          mode = "eager";
          ollama = {
            model = "qwen2.5-coder:7b";
            prompt_format = "qwen";
          };
        };
        language_models = {
          ollama = lib.mkIf osConfig.mx.services.llm.enable {
            api_url = "http://localhost:11434";
            available_models = [
              {
                display_name = "gemma4:e4b";
                max_tokens = 100000;
                name = "gemma4:e4b";
                supports_tools = true;
              }
              {
                display_name = "qwen3.5:9b";
                max_tokens = 262000;
                name = "qwen3.5:9b";
                supports_tools = true;
              }
              {
                display_name = "qwen2.5-coder:7b";
                max_tokens = 128000;
                name = "qwen2.5-coder:7b";
                supports_tools = true;
              }
            ];
          };
        };
        languages = {
          "C++" = {
            format_on_save = "on";
            tab_size = 4;
          };
          "Nix" = {
            format_on_save = "on";
            formatter = ["prettier"];
            language_servers = ["nixd"];
          };
          "Python" = {
            format_on_save = "on";
            formatter = [];
            language_servers = ["ruff" "pyright"];
          };
        };
        load_direnv = "shell_hook";
        lsp = {
          clangd = lib.mkIf config.mx.programs.dev.cpp {
            binary = {
              arguments = ["--compile-commands-dir=build"];
              path = "${pkgs-unstable.clang-tools}/bin/clangd";
            };
            initialization_options = {
              fallbackFlags = [
                "-I/chemin/vers/vos/includes"
                "-I/autre/chemin/include"
              ];
            };
          };
          nixd = {
            enable_lsp_tasks = true;
          };
          pyright = {
            settings = {
              python = {
                analysis = {
                  diagnosticMode = "workspace";
                  typeCheckingMode = "strict";
                };
                pythonPath = ".venv/bin/python";
              };
            };
          };
          rust-analyzer = {
            binary = {
              path = "${pkgs-unstable.rust-analyzer}/bin/rust-analyzer";
            };
          };
        };
        show_whitespaces = "none";
        show_wrap_guides = false;
        soft_wrap = "bounded";
        tab_bar = {
          show_tab_bar_buttons = true;
          show_nav_history_buttons = true;
          show = false;
        };
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        terminal = {
          show_count_badge = false;
          alternate_scroll = "off";
          blinking = "off";
          button = false;
          copy_on_select = false;
          detect_venv = {
            on = {
              activate_script = "default";
              directories = [".env" "env" ".venv" "venv"];
            };
          };
          dock = "bottom";
          env = {
            TERM = "alacritty";
          };
          font_features = null;
          font_size = null;
          line_height = "comfortable";
          option_as_meta = false;
          scrollbar = {
            show = "never";
          };
          shell = "system";
          toolbar = {
            breadcrumbs = false;
          };
          working_directory = "current_project_directory";
        };
        theme = {
          dark = "One Dark";
          light = "One Light";
          mode = "system";
        };
        ui_font_size = 16;
      };
    };
  };
}

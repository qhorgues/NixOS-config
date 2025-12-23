{ pkgs, ... }:

{
  home.packages = with pkgs; [
    sqlite
  ];

  programs.vscode = {
    enable = true;
    profiles.default = {
      # Extensions à installer
      extensions = with pkgs.vscode-extensions; [
        ms-vscode.cpptools-extension-pack
        ms-python.python
        ms-python.pylint
        charliermarsh.ruff
        ms-vscode.hexeditor
        rust-lang.rust-analyzer
        visualstudioexptteam.vscodeintellicode
        ms-vsliveshare.vsliveshare
        yy0931.vscode-sqlite3-editor
      ];

      # Fichier settings.json
      userSettings = {
        files.autoSave = "onFocusChange";
        editor.formatOnSave = true;
        terminal.integrated.enableImages = true;
        git.autofetch = false;
        "[python]" = {
          editor.defaultFormatter = "charliermarsh.ruff";
          editor.formatOnSave = true;
          editor.codeActionsOnSave = {
            "source.fixAll.ruff" = "always";
          };
        };
        workbench.startupEditor = "none";
        explorer.confirmDelete = false;
        security.workspace.trust.untrustedFiles = "open";
        explorer.confirmDragAndDrop = false;
        remote.tunnels.alwaysUpdateCLI = true;
        debug.onTaskErrors = "debugAnyway";
        extensions.ignoreRecommendations = true;
        scm.alwaysShowRepositories = true;
        scm.alwaysShowActions = true;
        scm.defaultViewMode = "tree";
        git.confirmSync = false;
        window.autoDetectColorScheme = true;
        workbench.colorCustomizations = {};
        workbench.settings.applyToAllProfiles = [ "workbench.colorCustomizations" ];
        "[jsonc]" = {
          editor.defaultFormatter = "vscode.json-language-features";
        };
        editor.fontLigatures = true;
        # editor.fontFamily = "'JetBrains Mono',";
        workbench.tree.indent = 10;
        editor.cursorStyle = "line";
        editor.cursorBlinking = "smooth";
        terminal.integrated.fontFamily = "Monospace";
        terminal.integrated.fontLigatures.enabled = true;
        editor.fontSize = 12;
        terminal.integrated.fontSize = 11;
        chat.editor.fontSize = 11;
        editor.minimap.enabled = false;
        editor.lineNumbers = "on";
        workbench.editor.showTabs = "none";
        files.trimTrailingWhitespace = true;
        files.trimFinalNewlines = true;
        files.insertFinalNewline = true;
        editor.wordWrap = "on";
        workbench.panel.showLabels = false;
        workbench.editor.enablePreview = false;
        workbench.activityBar.location = "top";
        ruff.nativeServer = "on";
        github.copilot = {
          chat = {
            followUps = "never";
            scopeSelection = false;
            codesearch.enabled = false;
            editor.temporalContext.enabled = false;
            edits.temporalContext.enabled = false;
            generateTests.codeLens = false;
            newWorkspaceCreation.enabled = false;
            search.semanticTextResults = false;
            edits.codesearch.enabled = false;
            languageContext.typescript.enabled = false;
          };
          nextEditSuggestions.enabled = false;
        };
        telemetry.telemetryLevel = "off";
        window.menuBarVisibility = "toggle";
        workbench.layoutControl.enabled = false;
        workbench.editor.editorActionsLocation = "hidden";
        workbench.navigationControl.enabled = false;
        window.commandCenter = false;
        application.experimental.rendererProfiling = true;
        window.titleBarStyle = "custom";
        doxdocgen.c.firstLine = "/***********************************";
        doxdocgen.c.lastLine = " ***********************************/";
        window.customTitleBarVisibility = "auto";
        C_Cpp.default.cppStandard = "c++23";
        C_Cpp.default.cStandard = "c23";
        terminal.integrated.defaultProfile.linux = "zsh";
        terminal.integrated.profiles.linux = {
          zsh = {
            path = "host-spawn";
            args = [ "zsh" ];
          };
        };
        catppuccin.accentColor = "sapphire";
        python.analysis.ignore = [ "*" ];
        github.copilot.enable = {
          "*" = false;
          plaintext = false;
          markdown = false;
          scminput = false;
        };
        terminal.integrated.gpuAcceleration = "on";
        workbench.preferredDarkColorTheme = "Visual Studio Dark";
      };

      # Keybindings personnalisés
      keybindings = [
        {
          key = "ctrl+shift+d";
          command = "doxdocgen.generateDocumentationComment";
          when = "editorTextFocus";
        }
        {
          key = "ctrl+/";
          command = "editor.action.commentLine";
          when = "editorTextFocus && !editorReadonly";
        }
      ];
    };
  };
}

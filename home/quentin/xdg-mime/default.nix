{ config, lib, ... }:
let
  cfg = config.mx.xdg.mimeApps;

  textEditor = "org.gnome.TextEditor.desktop";
  archiver = "org.gnome.FileRoller.desktop";
  office = "onlyoffice-desktopeditors.desktop";
  mail = "thunderbird.desktop";

  associations = {
    "application/pdf" = "org.gnome.Papers.desktop";

    "application/vnd.openxmlformats-officedocument.presentationml.presentation" = office;
    "text/csv" = office;

    "text/markdown" = textEditor;
    "text/javascript" = textEditor;
    "application/json" = textEditor;
    "application/sql" = textEditor;
    "image/svg+xml" = textEditor;
    "application/x-shellscript" = textEditor;
    "application/x-desktop" = textEditor;
    "application/vnd.ms-publisher" = textEditor;

    "application/zip" = archiver;
    "application/vnd.rar" = archiver;

    "application/vnd.sqlite3" = "dbeaver.desktop";
    "video/vnd.radgamettools.bink" = "org.gnome.Showtime.desktop";

    "x-scheme-handler/mailto" = mail;
    "x-scheme-handler/mid" = mail;
    "message/rfc822" = mail;
    "x-scheme-handler/webcal" = mail;
    "x-scheme-handler/webcals" = mail;
    "text/calendar" = mail;
    "application/x-extension-ics" = mail;
    "x-scheme-handler/net.thunderbird" = mail;

    "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
  };
in
{
  options.mx.xdg.mimeApps = {
    enable = lib.mkEnableOption "Manage ~/.config/mimeapps.list declaratively";
  };

  config = lib.mkIf cfg.enable {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = associations;
      associations.added = associations;
    };
  };
}

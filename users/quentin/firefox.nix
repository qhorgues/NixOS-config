{ pkgs-unstable, ... }:

{
  programs.firefox = {
    enable = true;
    languagePacks = [
    "fr"
    "en-US"
    ];
    nativeMessagingHosts = [ pkgs-unstable.firefoxpwa ];
    profiles."default" = {
      settings = {
        "browser.tabs.vertical" = true;
        "browser.ui.layout" = "vertical-tabs"; # Permet d'activer les onglets verticaux nativement
      };
      search = {
        force = true;
        default = "ddg";
        order = [ "ddg" "qwant" ];
      };
    };
  };
  home.packages = [
      pkgs-unstable.firefoxpwa
  ];
}

{ pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    languagePacks = [
    "fr"
    "en-US"
    ];
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
}

{ ... }:
{
  imports = [
    ../../modules/home-manager
  ];

  home.username = "elise";
  home.homeDirectory = "/home/elise";

  winter = {
    programs = {
      firefox.enable = true;
      office.enable = false;
    };
  };

  home.keyboard = {
    layout = "fr";
    variant = "fr";
  };
}

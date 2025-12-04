{ ... }: {
  programs.git = {
    enable = true;
    settings.user = {
      name  = "qhorgues";
      email = "quentin.horgues@outlook.fr";
    };
  };
}

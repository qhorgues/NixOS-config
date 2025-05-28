{ pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nix-channel --update
                sudo nix-env -u --always
                sudo nixos-rebuild boot --upgrade-all
                sudo rm /nix/var/nix/gcroots/auto/*
                sudo nix-store --gc
                sudo nix-collect-garbage -d
                ";
      clean  = "sudo nix-env -u --always
                sudo nix-store --gc
                ";
      killall = "pgrep -d ' ' $1 | xargs kill -15";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };
}

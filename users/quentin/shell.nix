{ ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    history.size = 10000;
    shellAliases = {
      ll = "ls -l";
      # update = "sudo nix-channel --update
      #           sudo nix-env -u --always
      #           sudo nixos-rebuild boot --flakes . --upgrade-all
      #           sudo rm /nix/var/nix/gcroots/auto/*
      #           sudo nix-store --gc
      #           sudo nix-collect-garbage -d
      #           ";
      clean  = "sudo nix-env -u --always
                sudo nix-store --gc
                ";
      killall = "pgrep -d ' ' $1 | xargs kill -15";
      srihash=''function _srihash() {
        nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url "$1")"
      }; _srihash'';
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
      theme = "robbyrussell";
    };
  };
}

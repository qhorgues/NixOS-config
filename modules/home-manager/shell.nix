{ ... }:
{
    programs.zsh = {
        enable = true;
        enableCompletion = true;
        autosuggestion.enable = true;
        syntaxHighlighting.enable = true;
        history.size = 10000;
        shellAliases = {
        ll = "ls -l";
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

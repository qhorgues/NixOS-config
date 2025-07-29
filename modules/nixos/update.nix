{ ... }:

{
    nix.settings.auto-optimise-store = true;
    nix.gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 5d";
    };
    services.fwupd.enable = true;
}

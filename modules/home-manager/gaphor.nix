{ lib, pkgs, ...}:

{
  home.packages = [
      (import ../../pkgs/gaphor.nix {inherit lib pkgs;})
    ];
}


{ ... }:

{
  imports = [
    ./app-options/only-office.nix
    ./custom-fonts/cooper-black.nix
  ];

  programs.onlyoffice.enable = true;
}

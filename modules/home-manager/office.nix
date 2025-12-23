{ pkgs, ... }:

{
  home.packages = with pkgs; [
    texliveFull
    (pkgs.texstudio.overrideAttrs (oldAttrs: {
        nativeBuildInputs = oldAttrs.nativeBuildInputs or [] ++ [ pkgs.makeWrapper ];
        postFixup = ''
          wrapProgram $out/bin/texstudio \
            --prefix XDG_DATA_DIRS : "${pkgs.gsettings-desktop-schemas}/share/gsettings-schemas/${pkgs.gsettings-desktop-schemas.name}" \
            --prefix XDG_DATA_DIRS : "${pkgs.gtk3}/share/gsettings-schemas/${pkgs.gtk3.name}"
        '';
      }))
    gsettings-desktop-schemas
    onlyoffice-desktopeditors
    libreoffice
    thunderbird-latest-bin
  ];
}

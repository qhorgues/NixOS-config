{ pkgs ? import <nixpkgs> { }
, game
, saveBase
, savePath
, steamLibrary
, steamId
, files
}:

let
  GREEN = "\\e[1;32m";
  RED   = "\\e[1;31m";
  RESET = "\\e[0m";

  saveDir = "${saveBase}/${savePath}";
  prefixDir = "${steamLibrary}/steamapps/compatdata/${steamId}/pfx/drive_c";

  # Génère les lignes de copie pour tous les fichiers
  makeCopyLines = { src, dst }: ''
    if [ ! -f "${src}" ]; then
      echo -e "${RED}Erreur : introuvable : ${src}${RESET}" >&2
      exit 1
    fi
    cp "${src}" "${dst}"
    echo -e "${GREEN}  ✔ ${src}${RESET}"
  '';

  makeApplyLines = gpu: { winPath, fileName }: makeCopyLines {
    src = "${saveDir}/${fileName} -- ${gpu}";
    dst = "${prefixDir}/${winPath}/${fileName}";
  };

  makeSetLines = gpu: { winPath, fileName }: makeCopyLines {
    src = "${prefixDir}/${winPath}/${fileName}";
    dst = "${saveDir}/${fileName} -- ${gpu}";
  };

  # Concatène les lignes pour tous les fichiers
  allCopyLines = f: builtins.concatStringsSep "\n" (map f files);

  # save → jeu : applique un profil
  makeApplyScript = { gpu }:
    pkgs.writeShellScriptBin "${game}-config-${gpu}" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      echo -e "${GREEN}Application du profil ${gpu}...${RESET}"
      ${allCopyLines (makeApplyLines gpu)}
      echo -e "${GREEN}✔ Profil ${gpu} appliqué avec succès${RESET}"
    '';

  # jeu → save : enregistre la config actuelle comme profil
  makeSetScript = { gpu }:
    pkgs.writeShellScriptBin "${game}-set-${gpu}" ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail

      echo -e "${GREEN}Sauvegarde du profil ${gpu}...${RESET}"
      ${allCopyLines (makeSetLines gpu)}
      echo -e "${GREEN}✔ Config actuelle sauvegardée comme profil ${gpu}${RESET}"
    '';

in
pkgs.symlinkJoin {
  name = "${game}-config-switcher";

  paths = [
    (makeApplyScript { gpu = "igpu"; })
    (makeApplyScript { gpu = "dgpu"; })
    (makeSetScript   { gpu = "igpu"; })
    (makeSetScript   { gpu = "dgpu"; })
  ];

  meta = {
    description = "Switcher de configuration ${game} (iGPU / dGPU)";
    mainProgram  = "${game}-config-dgpu";
  };
}

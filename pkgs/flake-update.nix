{ pkgs ? import <nixpkgs> {}, nix-latest-update, flake_path, flake_config }:

pkgs.writeShellScriptBin "flake-update" ''
    if ! ${pkgs.git}/bin/git diff-index --quiet HEAD --; then
      echo "Le dépôt contient des modifications non commités. Abandon."
      exit 1
    fi

    ${pkgs.nix}/bin/nix flake update --flake ${flake_path}

    cd ${flake_path}
    ${pkgs.git}/bin/git add flake.lock
    ${pkgs.git}/bin/git commit -m "update"


    if ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake_path}\#${flake_config}; then
      git push
      echo "✅ Mise à jour avec succès"
      ${nix-latest-update}/bin/nix-latest-update
    else
      echo "Échec de la mise à jour"
      git reset --hard HEAD~1
    fi
''

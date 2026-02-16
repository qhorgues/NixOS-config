{ pkgs ? import <nixpkgs> {}, nix-latest-update, flake_path, flake_config }:

pkgs.writeShellScriptBin "nix-update" ''
    cd ${flake_path}

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo -e "$RED Error: This directory is not a git repository $NC"
        exit 1
    fi

    PULL_OUTPUT=$(LANG=C ${pkgs.git}/bin/git pull 2>&1)
    PULL_EXIT_CODE=$?
    if echo "$PULL_OUTPUT" | grep -qi "conflict"; then
        echo -e "$RED Conflic detected in pull $NC"
        echo -e "$YELLOW Cancel pull $NC"

        # Annuler le merge en cours
        git merge --abort 2>&1

        # Vérifier que nous sommes revenus au commit d'origine
        if [ "$(git rev-parse HEAD)" = "$CURRENT_COMMIT" ]; then
            echo -e "$GREEN Pull aborted successfully. Repository restored to previous state.$NC"
        else
            echo -e "$RED Warning: Repository might not be in the expected state. $NC"
        fi
        exit 2
    fi

    # Check if the repository is already up to date
    if echo "$PULL_OUTPUT" | grep -qi "Already up to date\|Already up-to-date\|Déjà à jour"; then
        echo -e "$GREEN OS already up to date.$NC"
        exit 0
    fi

    # Check if pull succeeded (exit code 0)
    if [ $PULL_EXIT_CODE -eq 0 ]; then
        echo -e "$GREEN Starting update... $NC"

        sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake_path}\#${flake_config}
        COMMAND_EXIT_CODE=$?

        if [ $COMMAND_EXIT_CODE -eq 0 ]; then
            echo -e "$GREEN Update finish successfully!$NC"
            ${nix-latest-update}/bin/nix-latest-update
        else
            echo -e "$RED Update failed$NC"
            exit $COMMAND_EXIT_CODE
        fi
    else
        exit $PULL_EXIT_CODE
    fi
''

/*
pkgs.writeShellScriptBin "nix-update" ''
    cd ${flake_path}
    if ! ${pkgs.git}/bin/git diff-index --quiet HEAD --; then
        ${pkgs.coreutils}/bin/echo "The repository contains uncommitted changes. Cancelled."
        exit 1
    fi

    ${pkgs.nix}/bin/nix flake update --flake ${flake_path}

    ${pkgs.git}/bin/git add flake.lock > /dev/null 2>&1
    ${pkgs.git}/bin/git commit -m "update" > /dev/null 2>&1


    if sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch --flake ${flake_path}\#${flake_config}; then
        ${pkgs.git}/bin/git push > /dev/null 2>&1
        ${pkgs.coreutils}/bin/echo "Updated successfully"
        ${nix-latest-update}/bin/nix-latest-update
        exit 0
    else
        ${pkgs.coreutils}/bin/echo "Update failed"
        ${pkgs.git}/bin/git reset --hard HEAD~1 > /dev/null 2>&1
        exit 1
    fi
''
*/

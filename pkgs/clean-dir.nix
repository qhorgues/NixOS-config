{ pkgs ? import <nixpkgs> {} }:

pkgs.writeShellScriptBin "clean-dir" ''
  #!${pkgs.bash}/usr/bin/bash

  BLACK="\033[30m"
  RED="\e[1;31m"
  GREEN="\e[1;32m"
  YELLOW="\e[1;33m"
  BLUE="\e[1;34m"
  PINK="\033[35m"
  CYAN="\033[36m"
  WHITE="\033[37m"
  NORMAL="\033[0;39m"

  function rm_item () {
	if [ -d $1 ] || [ -f $1 ]; then
		${pkgs.coreutils}/bin/echo -e $GREEN'  'Remove$NORMAL $1;
		${pkgs.coreutils}/bin/rm -rf $1;
	fi
  }

  function rm_list () {
	for item in $@; do
		rm_item $item;
	done
  }

  function rm_executable() {
    rm_list $(${pkgs.findutils}/bin/find -type f -print0 | ${pkgs.findutils}/bin/xargs -0 -r file | ${pkgs.gnugrep}/bin/grep "ELF.*executable"| ${pkgs.gawk}/bin/awk -F: '{print $1}' ORS=' ')
  }

  function rm_dir () {
	rm_list $(${pkgs.findutils}/bin/find -name $1 -type d)
  }

  function rm_win_exe () {
	rm_list $(${pkgs.findutils}/bin/find -name *.exe -type f)
  }

  function clean_rust_dir () {
	current_dir=$(${pkgs.coreutils}/bin/pwd)
	for e in $(${pkgs.findutils}/bin/find -name Cargo.toml -type f -print0 | ${pkgs.findutils}/bin/xargs -r -0 dirname); do
		cd $e;
		${pkgs.coreutils}/bin/echo -e $BLUE'  '$PWD$NORMAL
		${pkgs.cargo}/bin/cargo clean;
		cd $current_dir
	done
  }

  allow_build_dir=();

  function clean_cmake_build_dir () {
	allow_build_dir=$(${pkgs.findutils}/bin/find -name Makefile -type f);
	for make in $allow_build_dir; do
		allow_build_dir+=("'$(${pkgs.coreutils}/bin/dirname $make)'");
		if $(test -e $(${pkgs.coreutils}/bin/dirname $(${pkgs.coreutils}/bin/dirname $make))/CMakeLists.txt); then
			${pkgs.coreutils}/bin/echo -e $GREEN'  Clean'$NORMAL $(${pkgs.coreutils}/bin/dirname $(${pkgs.coreutils}/bin/dirname $make));
			${pkgs.gnumake}/bin/make -s -C $(${pkgs.coreutils}/bin/dirname $make) clean;
		fi
	done
  }

  function clean_build_dir () {
	build=$(${pkgs.findutils}/bin/find -name build -type d)
	for build_path in $build; do
		not_found=true
		for element in "''${allow_build_dir[@]}"; do
			if [ "$element" == "'$build_path'" ]; then
				not_found=false
				break
      		fi
		done
		if $not_found; then
			rm_item $build_path
		fi
	done
  }



  # NPM
  ${pkgs.coreutils}/bin/echo -e $YELLOW Remove all npm dependancies$NORMAL
  rm_dir node_modules
  rm_dir .docusaurus

  #Python
  ${pkgs.coreutils}/bin/echo -e $YELLOW Remove all Python dependancies$NORMAL
  rm_dir .venv

  # Rust
  ${pkgs.coreutils}/bin/echo -e $YELLOW Remove all Rust build directories$NORMAL
  clean_rust_dir

  # Pour les projets C/C++ avec CMake
  ${pkgs.coreutils}/bin/echo -e $YELLOW Clean CMake C/C++ build directories$NORMAL
  clean_cmake_build_dir

  # Pour tout les autres build
  ${pkgs.coreutils}/bin/echo -e $YELLOW Remove other build directories$NORMAL
  clean_build_dir

  # Executable
  ${pkgs.coreutils}/bin/echo -e $YELLOW Remove all executables$NORMAL
  rm_executable
  rm_win_exe

''

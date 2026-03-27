{ pkgs, modulix-os-pkgs-unstable, config, lib, ... }:

let
  cfg = config.mx.programs.dev;
in
{
  options.mx.programs.dev = {
    enable = lib.mkEnableOption "Enable dev tools";
    nix = lib.mkEnableOption "Enable Nix dev tools";
    cpp = lib.mkEnableOption "Enable C/C++ dev tools";
    mpi-lib = lib.mkEnableOption "Enable MPI lib dev tools";
    openmp-lib = lib.mkEnableOption "Enable OpenMP dev tools";
    rust = lib.mkEnableOption "Enable Rust dev tools";
    python = lib.mkEnableOption "Enable Python dev tools";
    node = lib.mkEnableOption "Enable NodeJS dev tools";
    php = lib.mkEnableOption "Enable PHP/Laravel dev tools";
    sql = lib.mkEnableOption "Enable SQL dev tools";
    ci = lib.mkEnableOption "Enable CI dev tools";
    java = lib.mkEnableOption "Enable Java dev tools";
    gnome-dev = lib.mkEnableOption "Enable GNOME dev tools";
  };

  imports = [
    ./git.nix
  ];

  config = lib.mkMerge [
    (
      lib.mkIf cfg.enable {
        home.packages = with pkgs; [
          zeal
          git
        ] ++ lib.optionals cfg.nix [
          nil
          nixd # Nix language server for zeditor
          alejandra
        ] ++ lib.optionals cfg.cpp [
          # C / C++
          clang-tools
          clang
          cmakeWithGui
          gnumake
        ] ++ lib.optionals cfg.mpi-lib [
          openmpi
          openmpi.dev
        ] ++ lib.optionals cfg.openmp-lib [
          llvmPackages.openmp
          llvmPackages.openmp.dev
        ] ++ lib.optionals cfg.rust [
          # Rust
          cargo
          rustc
          rust-analyzer
          clang
          pkg-config
        ] ++ lib.optionals cfg.node [
          # Node
          bun
          nodejs
          npm-check-updates
        ] ++ lib.optionals cfg.python [
          # Python
          python3
          uv
          ruff
          nix-ld
        ] ++ lib.optionals cfg.php [
          # PHP / Laravel
          php84
          php84Packages.composer
          laravel
          filezilla
          modulix-os-pkgs-unstable.bruno
        ] ++ lib.optionals cfg.sql [
          mysql-workbench
          dbeaver-bin
        ] ++ lib.optionals cfg.gnome-dev [
          # Gnome app dev suite
          dconf-editor
          cambalache
          gnome-builder
          flatpak
          flatpak-builder
        ] ++ lib.optionals cfg.ci [
          act
        ] ++ lib.optionals cfg.java [
          java-language-server
          jdk
          gradle
        ];
      }
    )
    (
      lib.mkIf (cfg.enable && cfg.node) {
        home.sessionPath = [
          "${config.home.homeDirectory}/.bun/bin"
        ];
      }
    )
    (
      lib.mkIf (cfg.enable && (cfg.mpi-lib || cfg.openmp-lib)) {
        home.file.".clangd".text =
          let
            flags = lib.optionals cfg.mpi-lib [
              "-I${pkgs.openmpi.dev}/include"
            ] ++ lib.optionals cfg.openmp-lib [
              "-I${pkgs.llvmPackages.openmp.dev}/include"
            ];
          in
          lib.optionalString (flags != []) ''
            CompileFlags:
              Add:
            ${lib.concatMapStrings (f: "    - ${f}\n") flags}
          '';
      }
    )
  ];
}

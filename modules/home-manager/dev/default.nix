{ pkgs, config, lib, ... }:

let
  cfg = config.winter.programs.dev;
in
{
  options.winter.programs.dev = {
    enable = lib.mkEnableOption "Enable dev tools";
    nix = lib.mkEnableOption "Enable Nix dev tools";
    cpp = lib.mkEnableOption "Enable C++ dev tools";
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
        ] ++ lib.optionals cfg.rust [
          # Rust
          cargo
          rustc
          rust-analyzer
          clang
          pkg-config
          openssl
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
          bruno
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
  ];
}

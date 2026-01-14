{ pkgs, lib, config, ... }:

let
  cfg = config.winter.services.mariadb;
  phpmyadmin = import ../../../pkgs/phpmyadmin.nix {inherit lib pkgs;};
in
{
  options.winter.services.mariadb = {
    enable = lib.mkEnableOption "Enable MariaDB database";
  };

  config = lib.mkIf cfg.enable {
    services.httpd.enable = true;
    services.httpd.adminAddr = "webmaster@local.org";
    services.httpd.enablePHP = true;

    services.httpd.virtualHosts."local" = {
      documentRoot = "/var/www/html/";
      extraConfig = ''
          DirectoryIndex index.php index.html
          <Directory "/var/www/html/">
            Options Indexes FollowSymLinks
            AllowOverride All
            Require all granted
          </Directory>
          Alias /phpmyadmin "${phpmyadmin}/share/phpmyadmin"
          <Directory "${phpmyadmin}/share/phpmyadmin">
            Require all granted
            Options Indexes FollowSymLinks
          </Directory>
        '';
      # want ssl + a let's encrypt certificate? add `forceSSL = true;` right here
    };

    services.mysql.enable = true;
    services.mysql.package = pkgs.mariadb;

    # hacky way to create our directory structure and index page... don't actually use this
    systemd.tmpfiles.rules = [
      "d /var/www/html/"
      "f /var/www/html/index.php - - - - <?php phpinfo();?>"
      "L /var/www/html/phpmyadmin - - - - ${phpmyadmin}/share/phpmyadmin"
    ];
  };

}

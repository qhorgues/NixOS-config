{ pkgs, lib, ... }:

let
  phpmyadmin = import ../../pkgs/phpmyadmin.nix {inherit lib pkgs;};
in
{
  services.httpd.enable = true;
  services.httpd.adminAddr = "webmaster@local.org";
  services.httpd.enablePHP = true; # oof... not a great idea in my opinion

  services.httpd.virtualHosts."local" = {
    documentRoot = "/var/www/";
    extraConfig = ''
        DirectoryIndex index.php index.html
        <Directory "/var/www/">
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
    "d /var/www/"
    "f /var/www/index.php - - - - <?php phpinfo();?>"
    "L /var/www/phpmyadmin - - - - ${phpmyadmin}/share/phpmyadmin"
  ];

}

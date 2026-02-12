{ config, pkgs, lib, ... }:

let
  cfg = config.winter.services.postgresql;
in
{
  options.winter.services.postgresql = {
    enable = lib.mkEnableOption "Enable postgresql database";
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      settings = {
          listen_addresses = lib.mkDefault "127.0.0.1";
      };
      # authentication = ''
      #     # TYPE  DATABASE        USER            ADDRESS                 METHOD
      #     local   all             user1sa                                 md5
      #     local   all             user2bdr                                md5
      #     local   all             user3		                                md5
      #     local   all             user4		                                md5
      #     local   all             user5		                                md5
      #     local   all             user6		                                md5
      #     local   replication     postgres                                trust
      #     host    all             all             127.0.0.1/32            trust
      #     host    all             all             ::1/128                 trust
      #     local   all             all                                     trust
      # '';
      # settings = {
      #   archive_mode = "on";
      #   restore_command = "cp /tmp/wal_archive/%f \"%p\"";
      #   archive_command = "test ! -f /var/lib/postgresql/wal_archive/%f && cp %p /var/lib/postgresql/wal_archive/%f";
      #   wal_level = "replica";
      #   archive_timeout = 60;
      # };
    };

    systemd.services.postgresql = {
      wantedBy = [ "multi-user.target" ];
    };
    environment.systemPackages = with pkgs; [
      dbeaver-bin
    ];
  };
}

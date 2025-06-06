{ pkgs, lib, ... }:

{
  services.postgresql = {
    enable = true;
    settings = {
        listen_addresses = lib.mkForce "127.0.0.1";
    };
    authentication = ''
        # TYPE  DATABASE        USER            ADDRESS                 METHOD
        local   all             user1sa                                 md5
        local   all             user2bdr                                md5
        local   all             user3		                                md5
        local   all             user4		                                md5
        local   all             user5		                                md5
        local   all             user6		                                md5
        host    all             all             127.0.0.1/32            trust
        host    all             all             ::1/128                 trust
        local   all             all                                     trust
    '';
  };

  systemd.services.postgresql = {
    wantedBy = [ "multi-user.target" ];
  };
  environment.systemPackages = with pkgs; [
    dbeaver-bin
  ];
}

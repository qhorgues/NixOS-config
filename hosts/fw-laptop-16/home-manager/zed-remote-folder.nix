{ ... }:
{
    programs.zed-editor.userSettings = {
      ssh_connections = [
          {
              host = "192.168.122.184";
              projects = [
                  {
                      paths = [
                          "~/Programmes/CppLayerPHP"
                          "/var/www/api"
                      ];
                  }
              ];
              args = [
                  "-i"
                  "~/.ssh/id_rsa"
              ];
              port = 22;
              username = "quentin";
        }
        {
          host = "57.128.4.193";
          projects = [
            {
              paths = [
                "~/app-backend"
              ];
            }
          ];
          args = [
              "-i"
              "~/.ssh/id_ed25519"
          ];
          username = "quentin";
        }
      ];
    };
}

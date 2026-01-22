{ ... }:
{
    programs.zed-editor.userSettings = {
      ssh_connections = [
          {
            hostname = "rpi-quentin-proxy";
            project = [
              {
                paths = [
                    "~/app-backend"
                ];
              }
            ];
          }
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
      ];
    };
}

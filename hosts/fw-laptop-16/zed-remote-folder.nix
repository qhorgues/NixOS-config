{ ... }:
{
    programs.zed-editor.userSettings = {
      ssh_connections = [
          {
            host = "aiotlab.viu.edu.vn";
            projects = [
                {
                    paths = [
                        "~/PERSON_RLF"
                    ];
                }
            ];
            username = "quentin.horgues";
            port = 30101;
          }
          {
            host = "rpi-horgues";
            projects = [
              {
                paths = [
                    "/etc/nixos"
                ];
              }
            ];
          }
          {
            host = "rpi-quentin-proxy";
            projects = [
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

{ ... }:
{
    programs.zed-editor.userSettings = {
      ssh_connections = [
          {
              host = "192.168.122.62";
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
                  "~/.ssh/id_ed25519_vm"
              ];
              port = 22;
              username = "quentin";
        }
      ];
    };
}

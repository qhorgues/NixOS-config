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
                      ];
                  }
              ];
              args = [
                  "-i"
                  "~/.ssh/id_ed25519.pub"
              ];
              port = 22;
              username = "quentin";
        }
      ];
    };
}

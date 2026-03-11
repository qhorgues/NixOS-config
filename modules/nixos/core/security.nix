{ lib, ... }:

{
  security.rtkit.enable = lib.mkDefault true;
  security.apparmor.enable = lib.mkDefault false;
  services.gnome.gnome-keyring.enable = lib.mkDefault true;
  security.pam.services.login.enableGnomeKeyring = lib.mkDefault true;

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  boot.initrd.systemd = {
    enable = true;
    tpm2.enable = true;
  };


  # Dans ta configuration NixOS
  security.polkit.enable = true;

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      var allowedUnits = [
        "docker.service", "docker.socket",
        "ollama.service",
        "open-webui.service",
        "httpd.service", "mysql.service",
        "postgresql.service",
        "cups.service", "cups.socket",
        "teamviewerd.service",
        "libvirtd.service", "libvirtd.socket",
        "virtlogd.service", "virtlogd.socket"
      ];

      if (action.id === "org.freedesktop.systemd1.manage-units" &&
          subject.isInGroup("wheel") &&
          allowedUnits.indexOf(action.lookup("unit")) !== -1) {
        return polkit.Result.YES;
      }

      if (action.id === "org.freedesktop.UPower.PowerProfiles.switch-profile" &&
          subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }

      return polkit.Result.NO;
    });
  '';
}

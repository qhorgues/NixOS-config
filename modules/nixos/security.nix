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
    enableTpm2 = true;
  };
}

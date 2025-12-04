{ config, pkgs, ... }:

{
  # Installation de Discord
  home.packages = with pkgs; [
    discord
  ];

  # Configuration AppArmor pour Discord
  # Version minimaliste : sans stats système, sans Vulkan, avec Pipewire

  home.file.".config/apparmor.d/discord".text = ''
    profile discord ${pkgs.discord}/bin/discord {
      #include <abstractions/base>
      #include <abstractions/audio>
      #include <abstractions/dbus-session-strict>
      #include <abstractions/dbus-accessibility-strict>
      #include <abstractions/fonts>
      #include <abstractions/nameservice>
      #include <abstractions/openssl>
      #include <abstractions/ssl_certs>
      #include <abstractions/X>

      # Permissions réseau
      network inet stream,
      network inet6 stream,
      network inet dgram,
      network inet6 dgram,

      # Accès aux fichiers Discord
      owner ${config.home.homeDirectory}/.config/discord/ rw,
      owner ${config.home.homeDirectory}/.config/discord/** rwk,

      # Cache et données temporaires
      owner ${config.home.homeDirectory}/.cache/discord/ rw,
      owner ${config.home.homeDirectory}/.cache/discord/** rwk,

      # Téléchargements
      owner ${config.home.homeDirectory}/Downloads/ r,
      owner ${config.home.homeDirectory}/Downloads/** rw,
      owner ${config.home.homeDirectory}/Téléchargements/ r,
      owner ${config.home.homeDirectory}/Téléchargements/** rw,

      # Accès aux fichiers partagés
      owner ${config.home.homeDirectory}/Pictures/ r,
      owner ${config.home.homeDirectory}/Pictures/** r,
      owner ${config.home.homeDirectory}/Images/ r,
      owner ${config.home.homeDirectory}/Images/** r,
      owner ${config.home.homeDirectory}/Videos/ r,
      owner ${config.home.homeDirectory}/Videos/** r,
      owner ${config.home.homeDirectory}/Vidéos/ r,
      owner ${config.home.homeDirectory}/Vidéos/** r,
      owner ${config.home.homeDirectory}/Documents/ r,
      owner ${config.home.homeDirectory}/Documents/** r,

      # Binaires et bibliothèques nécessaires (Nix)
      ${pkgs.discord}/bin/discord rix,
      ${pkgs.discord}/** r,
      # /nix/store/** r,

      # GPU et accélération matérielle
      /dev/dri/ r,
      /dev/dri/card* rw,
      /dev/dri/renderD* rw,

      # Son
      /dev/snd/ r,
      /dev/snd/* rw,
      owner /run/user/*/pipewire-* rw,
      owner ${config.home.homeDirectory}/.local/state/pipewire/ rw,
      owner ${config.home.homeDirectory}/.local/state/pipewire/** rw,
      /usr/share/pipewire/** r,
      /etc/pipewire/** r,

      # Vulkan
      /sys/devices/pci*/**/config r,
      /usr/share/vulkan/icd.d/ r,
      /usr/share/vulkan/icd.d/*.json r,

      # Déni explicite de certains accès sensibles
      deny ${config.home.homeDirectory}/.ssh/** rw,
      deny ${config.home.homeDirectory}/.gnupg/** rw,
      deny ${config.home.homeDirectory}/.password-store/** rw,
      deny /etc/shadow r,
      deny /etc/passwd w,

      # Logs
      owner ${config.home.homeDirectory}/.local/share/discord/ rw,
      owner ${config.home.homeDirectory}/.local/share/discord/** rwk,
    }
  '';
}

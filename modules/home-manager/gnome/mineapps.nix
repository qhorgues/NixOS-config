{ ... }:
{
    home.file.".config/mimeapps.list".text = ''
        [Default Applications]
        # Vidéo
        video/mp4=showtime.desktop
        video/x-matroska=showtime.desktop
        video/x-msvideo=showtime.desktop
        video/webm=showtime.desktop

        # Audio
        audio/mpeg=decibels.desktop
        audio/mpeg=decibels.desktop
        audio/x-wav=decibels.desktop
        audio/ogg=decibels.desktop

        # Navigateur web
        x-scheme-handler/http=firefox.desktop
        x-scheme-handler/https=firefox.desktop
        text/html=firefox.desktop

        # Images
        image/jpeg=eog.desktop
        image/png=eog.desktop
        image/gif=eog.desktop
        image/webp=eog.desktop

        # Dossiers et fichiers
        inode/directory=nautilus.desktop
        application/pdf=org.gnome.Evince.desktop
      '';
}

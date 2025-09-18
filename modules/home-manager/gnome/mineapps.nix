{ ... }:
{
    home.file.".config/mimeapps.list".text = ''
        [Default Applications]
        video/mp4=org.gnome.Showtime.desktop;
        video/x-matroska=org.gnome.Showtime.desktop;
        video/x-msvideo=org.gnome.Showtime.desktop;
        video/vnd.radgamettools.bink=org.gnome.Showtime.desktop;
        video/webm=org.gnome.Showtime.desktop;
        audio/mpeg=org.gnome.Decibels.desktop;
        audio/mpeg=org.gnome.Decibels.desktop;
        audio/x-wav=org.gnome.Decibels.desktop;
        audio/ogg=org.gnome.Decibels.desktop;
        x-scheme-handler/http=firefox.desktop;
        x-scheme-handler/https=firefox.desktop;
        text/html=firefox.desktop;
        image/jpeg=org.gnome.Loupe.desktop;
        image/png=org.gnome.Loupe.desktop;
        image/gif=org.gnome.Loupe.desktop;
        image/webp=org.gnome.Loupe.desktop;
        image/svg+xml=org.inkscape.Inkscape.desktop;
        inode/directory=org.gnome.Nautilus.desktop;
        application/pdf=org.gnome.Papers.desktop;
        text/plain=org.gnome.TextEditor.desktop;
      '';
}

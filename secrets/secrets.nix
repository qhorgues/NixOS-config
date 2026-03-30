let
  # Framework laptop 16
  quentin-fw-laptop-16 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeDXES7JVBTFfXQTezi08nO8GQpWTiQP/myoLfpTAtD quentin@fw-laptop-quentin";

  host-fw-laptop-16 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiuqOPQqKnnYMBdZD++mF7ocTeHOv6Srzglz4KEfAK+ root@fw-laptop-16";

  quentin-rpi-horgues = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVhwvd2bh3QAIQkkXnPixksQV6tIw/VqbQeD405uYAF quentin@rpi-horgues";

  host-rpi-horgues = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIYn/xadR0hDoNy8CG7DYNZSju31zyPRxutjpDeejh6W root@nixos-installer";

  allHosts = [ host-fw-laptop-16 host-rpi-horgues ];
  allKeys  = [ quentin-fw-laptop-16 quentin-rpi-horgues ] ++ allHosts;
in
{
  # Secret spécifique à chaque machine
  "fw-laptop-16/wireguard-key.age".publicKeys  = [ quentin-fw-laptop-16 host-fw-laptop-16 ];

}

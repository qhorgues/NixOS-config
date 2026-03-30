let
  # Framework laptop 16
  quentin-fw-laptop-16 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHeDXES7JVBTFfXQTezi08nO8GQpWTiQP/myoLfpTAtD quentin@fw-laptop-quentin";

  host-fw-laptop-16 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBiuqOPQqKnnYMBdZD++mF7ocTeHOv6Srzglz4KEfAK+ root@fw-laptop-16";

  allHosts = [ host-fw-laptop-16 ];
  allKeys  = [ quentin-fw-laptop-16 ] ++ allHosts;
in
{
  # Secret spécifique à chaque machine
  "secrets/fw-laptop-16.age".publicKeys  = [ quentin-fw-laptop-16 host-fw-laptop-16 ];

  "secrets/shared.age".publicKeys = allKeys;
}

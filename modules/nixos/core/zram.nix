{ lib, ... }:

{
  boot.kernel.sysctl = {
    "vm.swappiness" = 100;
  };
  zramSwap = {
    enable = lib.mkDefault true;
    algorithm = "zstd";
    memoryPercent = lib.mkDefault 100;
    priority = 100;
  };
}

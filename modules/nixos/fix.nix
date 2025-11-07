{ pkgs, ... }:
{
  nixpkgs.overlays = [
    (self: super:
      let
        version = "20250808";
      in
      {
      linux-firmware = super.linux-firmware.overrideAttrs (old: {
        version = version;
        src = super.fetchurl {
          url = "https://cdn.kernel.org/pub/linux/kernel/firmware/linux-firmware-${version}.tar.xz";
          sha256 = "sha256-wClVG0WhWSbJ16XfGgtUAEQGTxkVfFf8Edkf0Kreg38=";
        };
      });
    })
  ];

}

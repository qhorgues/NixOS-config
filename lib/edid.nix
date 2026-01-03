{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:

let
  # Fonction puissance (2^n)
  pow2 = n:
    if n == 0 then 1
    else if n == 1 then 2
    else 2 * (pow2 (n - 1));

  # Fonction racine carrée (méthode de Newton-Raphson)
  sqrt = x: let
    # Approximation initiale
    guess = x / 2.0;
    # Itération pour améliorer la précision
    improve = g: (g + x / g) / 2.0;
    # 10 itérations suffisent pour une bonne précision
    iterate = g: n: if n == 0 then g else iterate (improve g) (n - 1);
  in if x == 0 then 0 else iterate guess 10;

  # Fonction pour convertir un entier en hex (00-FF)
  toHex = n: let
    digits = "0123456789abcdef";
    high = lib.substring (n / 16) 1 digits;
    low = lib.substring (lib.mod n 16) 1 digits;
  in high + low;

  # Fonctions de manipulation de bits
  bitAnd = a: b: builtins.bitAnd a b;
  bitOr = a: b: builtins.bitOr a b;
  # bitXor = a: b: builtins.bitXor a b;

  # Shift left: multiplier par 2^n
  bitShiftL = value: n: value * (pow2 n);

  # Shift right: diviser par 2^n (division entière)
  bitShiftR = value: n:
    if n == 0 then value
    else builtins.floor (value / (pow2 n));

  # Fonction pour calculer le checksum EDID
  calculateChecksum = bytes: let
    sum = lib.foldl' (acc: val: acc + val) 0 bytes;
    checksum = lib.mod (256 - (lib.mod sum 256)) 256;
  in checksum;

  # Fonction pour encoder un entier en little-endian sur N octets
  packLE = bits: value: let
    bytes = bits / 8;
    extract = n: lib.mod (bitAnd (bitShiftR value (n * 8)) 255) 256;
  in lib.genList extract bytes;

  # Fonction principale pour créer l'EDID
  createEdid = {
    width ? 1920,
    height ? 1080,
    refreshRate ? 60,
    enableHdr ? false,
    displayName ? "Custom Display"
  }: let

    # Calculs préliminaires
    diagonalInches = sqrt ((width * width) + (height * height)) / 96.0;
    aspectRatio = width / (height * 1.0);
    hSizeCm = builtins.floor ((diagonalInches * 2.54) / (sqrt (1 + (1 / (aspectRatio * aspectRatio)))));
    vSizeCm = builtins.floor (hSizeCm / aspectRatio);

    # Timing calculations
    hActive = width;
    vActive = height;
    hBlank = lib.max 80 (builtins.floor (width * 0.08));
    hTotal = hActive + hBlank;

    vBlankEstimate = lib.max 23 (builtins.floor (height * 0.025));
    pixelClockHz = hTotal * (vActive + vBlankEstimate) * refreshRate;
    vBlank = lib.max 23 (builtins.floor ((pixelClockHz / (hTotal * refreshRate)) - vActive));

    finalPixelClockHz = hTotal * (vActive + vBlank) * refreshRate;
    pixelClock = lib.min 65535 (builtins.floor (finalPixelClockHz / 10000));

    hSyncOffset = builtins.floor (hBlank * 0.2);
    hSyncWidth = builtins.floor (hBlank * 0.4);
    vSyncOffset = 2;
    vSyncWidth = 6;

    hSizeMm = hSizeCm * 10;
    vSizeMm = vSizeCm * 10;

    serial = bitOr (bitShiftL width 16) (bitOr (bitShiftL height 4) (bitAnd refreshRate 15));

    minVRate = lib.max 24 (refreshRate - 20);
    maxVRate = refreshRate + 20;

    # Nom du display (max 13 caractères, padded avec des espaces)
    nameBytes = let
      truncated = lib.substring 0 13 displayName;
      padded = truncated + lib.concatStrings (lib.genList (_: " ") (13 - lib.stringLength truncated));
    in lib.stringToCharacters padded;

    # Construction du bloc EDID de base (128 octets)
    baseBlock =
      # Header (8 bytes)
      [ 0 255 255 255 255 255 255 0 ]

      # Manufacturer ID "VHD" (3 bytes)
      ++ [ 86 36 ]

      # Product code (2 bytes)
      ++ (packLE 16 (if enableHdr then 18500 else 21316))

      # Serial number (4 bytes)
      ++ (packLE 32 serial)

      # Week, Year (2 bytes)
      ++ [ 1 33 ]

      # EDID version (2 bytes)
      ++ [ 1 4 ]

      # Video input definition (1 byte)
      ++ [ (if enableHdr then 181 else 165) ]

      # Screen size (2 bytes)
      ++ [ (lib.min hSizeCm 255) (lib.min vSizeCm 255) ]

      # Gamma (1 byte)
      ++ [ 220 ]

      # Feature support (1 byte)
      ++ [ (if enableHdr then 26 else 30) ]

      # Color characteristics (10 bytes)
      ++ [ 238 145 163 84 76 153 38 15 80 84 ]

      # Established timings (3 bytes)
      ++ [ 0 0 0 ]

      # Standard timings (16 bytes)
      ++ (lib.flatten (lib.genList (_: [ 1 1 ]) 8))

      # Detailed timing descriptor 1 (18 bytes)
      ++ (packLE 16 pixelClock)
      ++ [ (bitAnd hActive 255)
           (bitAnd hBlank 255)
           (bitOr (bitShiftL (bitShiftR hActive 8) 4) (bitShiftR hBlank 8))
           (bitAnd vActive 255)
           (bitAnd vBlank 255)
           (bitOr (bitShiftL (bitShiftR vActive 8) 4) (bitShiftR vBlank 8))
           (bitAnd hSyncOffset 255)
           (bitAnd hSyncWidth 255)
           (bitOr (bitShiftL (bitAnd vSyncOffset 15) 4) (bitAnd vSyncWidth 15))
           (bitOr
             (bitOr (bitShiftL (bitAnd (bitShiftR hSyncOffset 8) 3) 6)
                        (bitShiftL (bitAnd (bitShiftR hSyncWidth 8) 3) 4))
             (bitOr (bitShiftL (bitAnd (bitShiftR vSyncOffset 4) 3) 2)
                        (bitAnd (bitShiftR vSyncWidth 4) 3)))
           (bitAnd hSizeMm 255)
           (bitAnd vSizeMm 255)
           (bitOr (bitShiftL (bitShiftR hSizeMm 8) 4) (bitShiftR vSizeMm 8))
           0 0 24 ]

      # Display product name (18 bytes)
      ++ ([ 0 0 0 252 0 ] ++ (map (c: lib.strings.charToInt c) nameBytes))

      # Display range limits (18 bytes)
      ++ [ 0 0 0 253 0 minVRate maxVRate 30 160 220 0 10 32 32 32 32 32 32 ]

      # Dummy descriptor (18 bytes)
      ++ ([ 0 0 0 16 0 ] ++ (lib.genList (_: 0) 13))

      # Extension flag (1 byte)
      ++ [ 1 ];

    # Checksum du bloc de base
    baseBlockWithChecksum = baseBlock ++ [ (calculateChecksum baseBlock) ];

    # Construction du bloc CEA-861 (128 octets)
    ceaBlock = let
      # Header CEA
      header = [ 2 3 ];

      # Data blocks
      dataBlocks = if enableHdr then
        # Colorimetry Data Block (4 bytes)
        [ 227 5 224 0 ]
        # HDR Static Metadata Data Block (7 bytes)
        ++ [ 230 6 7 1 120 90 50 ]
        # Video Capability Data Block (3 bytes)
        ++ [ 226 0 0 ]
        # HDMI VSDB (8 bytes)
        ++ [ 103 216 93 196 1 120 0 0 ]
      else
        # Video Capability Data Block (3 bytes)
        [ 226 0 0 ]
        # HDMI VSDB (8 bytes)
        ++ [ 103 216 93 196 1 120 0 0 ];

      dtdOffset = 4 + (lib.length dataBlocks);

      # DTD dans le bloc CEA (copie du DTD du bloc de base)
      dtd = lib.sublist 54 18 baseBlockWithChecksum;

      # Construction complète
      content = header
                ++ [ dtdOffset 112 ]  # DTD offset + support flags
                ++ dataBlocks
                ++ dtd;

      # Padding jusqu'à 127 octets
      padded = content ++ (lib.genList (_: 0) (127 - (lib.length content)));

    in padded ++ [ (calculateChecksum padded) ];

    # EDID complet
    fullEdid = baseBlockWithChecksum ++ ceaBlock;

  in fullEdid;

in
{
  inherit createEdid;

  # Fonction helper pour écrire l'EDID dans un fichier binaire
  writeEdid = {displayName, ...}@args:
    pkgs.runCommand "${displayName}" {} ''
        ${lib.concatMapStringsSep "\n" (byte:
        "printf '\\x${toHex byte}' >> $out"
        ) (createEdid args)}
  '';

  # Pour tester en CLI directement
  # testEdid = pkgs.writeShellScriptBin "generate-edid" ''
  #   # Générer l'EDID par défaut
  #   (
  #   ${lib.concatMapStringsSep "\n" (byte:
  #     "printf '\\x${toHex byte}'"
  #   ) (createEdid {
  #     width = 2560;
  #     height = 1440;
  #     refreshRate = 144;
  #     enableHdr = false;
  #     displayName = "1440p";
  #   })}
  #   ) > 1440p
  #
  #   echo "EDID généré: 1440p"
  #   ls -lh 1440p
  #
  #   # Afficher les infos avec edid-decode si disponible
  #   if command -v edid-decode &> /dev/null; then
  #     echo -e "\n=== Analyse EDID ==="
  #     edid-decode 1440p
  #   else
  #     echo -e "\nPour analyser l'EDID, installez edid-decode:"
  #     echo "  nix-shell -p edid-decode"
  #   fi
  # '';
}

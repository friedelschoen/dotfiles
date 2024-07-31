{ pkgs ? import <nixpkgs> { }
, configHeader
}:

with pkgs; stdenv.mkDerivation rec {
  name = "dmenu";
  src = fetchurl {
    url = "https://dl.suckless.org/tools/dmenu-5.2.tar.gz";
    hash = "sha256-1NTKd7WRQPJyJy21N+BbuRpZFPVoAmUtxX5hp3PUN5I=";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXinerama
    xorg.libXft
  ];

  patches = [
    ../patches/dmenu-dynamicoptions-5.2.diff

    (pkgs.fetchurl {
      url = https://tools.suckless.org/dmenu/patches/bar_height/dmenu-bar-height-5.2.diff;
      hash = "sha256-YzPGmjkjHNIy4kxsY5GthitR/jKkUE7Pl8I8C/pcSLo=";
    })
    (pkgs.fetchurl {
      url = https://tools.suckless.org/dmenu/patches/case-insensitive/dmenu-caseinsensitive-5.0.diff;
      hash = "sha256-TH/3HoIxkFJ+zqDuqISjQLmgjHlYlZKnopjrmxOoZ0U=";
    })
    (pkgs.fetchurl {
      url = https://tools.suckless.org/dmenu/patches/highlight/dmenu-highlight-4.9.diff;
      hash = "sha256-T0Y3YbFt/yVc7cTimJ8HZNQ9zKvd/G1XhfyimPaLQWA=";
    })
    (pkgs.fetchurl {
      url = https://tools.suckless.org/dmenu/patches/numbers/dmenu-numbers-20220512-28fb3e2.diff;
      hash = "sha256-dXAmbub13PUDjygoxsK0PNnCPc5yNWOIPtrNLvy8fSw=";
    })
  ];

  configurePhase = ''
    # ln -sf ${../assets/dmenu_path} dmenu_path
    # ln -sf ${configHeader} config.h
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

{ pkgs ? import <nixpkgs> { }
, configHeader
}:

with pkgs; stdenv.mkDerivation rec {
  name = "dwm";
  src = fetchGit {
    url = "https://git.friedelschoen.io/suckless/dwm";
    rev = "2f0245c39087b0dfce6bb6a1c5269936ab2106b8";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXft
    xorg.libXinerama
  ];

  configurePhase = ''
    cp ${configHeader} config.h
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

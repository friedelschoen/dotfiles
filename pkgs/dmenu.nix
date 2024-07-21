{ pkgs ? import <nixpkgs> { }
, colors ? [ ]
}:

with pkgs; stdenv.mkDerivation rec {
  name = "dmenu";
  src = fetchGit {
    url = "https://git.friedelschoen.io/suckless/dmenu";
    rev = "e9bea6daddb02bfdff2915ca781d03a4f071c5dd";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXinerama
    xorg.libXft
  ];

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

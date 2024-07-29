{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  name = "st";
  src = fetchGit {
    url = "https://git.friedelschoen.io/suckless/st";
    rev = "b878d53d99a3a7108107f2da3a856a90872ec6fd";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    fontconfig
    freetype
    xorg.libX11
    xorg.libXft
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

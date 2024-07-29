{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  name = "tabbed";
  src = fetchGit {
    url = "https://git.suckless.org/tabbed";
    rev = "7215169fbbb1f81c3bad49b847d1e5907f6ab70c";
  };

  buildInputs = [
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

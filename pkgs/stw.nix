{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation {
  name = "stw";
  src = fetchGit {
    url = "https://github.com/sineemore/stw";
    rev = "54377209c6313c9637aab904d06c5c383414a5ee";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    xorg.libXft
    fontconfig
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

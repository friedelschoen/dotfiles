{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  name = "tabbed";
  src = fetchurl {
    url = "https://dl.suckless.org/tools/tabbed-0.8.tar.gz";
    hash = "sha256-lb3/zLBxCDBo0rVVwlJOnHxXybZElNRsaX5njUmgo9c=";
  };

  buildInputs = [
    xorg.libXft
  ];

  configurePhase = ''
    ln -sf ${configHeader} config.h
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

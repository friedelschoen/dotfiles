{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  name = "surf";
  src = fetchurl {
    url = https://dl.suckless.org/surf/surf-2.1.tar.gz;
    hash = "sha256-cuWCkguiWmRiA+k8LSMx2H8DA3ooiU1sfpmvAO4EMlc=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    gcr
    gtk3-x11
    webkitgtk
    glib-networking
  ];

  patches = [
    (pkgs.fetchurl {
      url = https://surf.suckless.org/patches/homepage/surf-2.0-homepage.diff;
      hash = "sha256-hYBQeaNc0dCr/lE3c0aQO08q8Z+dB2SFryYGiBGZDzY=";
    })
    (pkgs.fetchurl {
      url = https://surf.suckless.org/patches/history/surf-2.1-history.diff;
      hash = "sha256-t7uI2SEjcG90xSp9g6lSheE9O+B9kx7Ggu9zlrt5X2o=";
    })
    (pkgs.fetchurl {
      url = https://surf.suckless.org/patches/clipboard-instead-of-primary/surf-clipboard-20200112-a6a8878.diff;
      hash = "sha256-eDwZ3KwCcETkPufWM52YyLKtVdc+PRNQZC1xI6ZYUFs=";
    })
    (pkgs.fetchurl {
      url = https://surf.suckless.org/patches/searchengines/surf-searchengines-20220804-609ea1c.diff;
      hash = "sha256-F99gbM9sDDdvDj11J22kn2fu6sIKehD3Ecjm3syb3IU=";
    })
    (pkgs.fetchurl {
      url = https://surf.suckless.org/patches/short-title/surf-short-title-20210206-7dcce9e.diff;
      hash = "sha256-763QcUq4c3Kj+tqjqrFFksMOuJFrnGg9ESt5eJIcaO4=";
    })
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

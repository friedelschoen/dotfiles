{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  pname = "st";
  version = "0.9.2";

  src = pkgs.fetchurl {
    url = "https://dl.suckless.org/st/st-${version}.tar.gz";
    hash = "sha256-ayFdT0crIdYjLzDyIRF6d34kvP7miVXd77dCZGf5SUs=";
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

  patches = [
    ../patches/st-remove-terminfo.diff
    ../patches/st-scrollback-ringbuffer.diff
    (pkgs.fetchurl {
      url = https://st.suckless.org/patches/anysize/st-anysize-20220718-baa9357.diff;
      hash = "sha256-eO8MEPRb3uaCTtBznG+LaojXqlcj4eT422rQgpxopfo=";
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

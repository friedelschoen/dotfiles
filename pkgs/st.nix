{ pkgs ? import <nixpkgs> { }, config ? { } }:

with pkgs; stdenv.mkDerivation rec {
  name = "st";
  src = fetchGit {
    url = "https://git.friedelschoen.io/suckless/st";
    rev = "c9b37cad883f0e811f2a4f11ead78649c0474f73";
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

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

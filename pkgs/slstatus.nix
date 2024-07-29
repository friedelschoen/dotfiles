{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  name = "slstatus";
  src = fetchGit {
    url = "https://git.friedelschoen.io/suckless/slstatus";
    rev = "02281e5587b82b790533d7c4bbd146c561ee219c";
  };

  buildInputs = [
    xorg.libX11
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

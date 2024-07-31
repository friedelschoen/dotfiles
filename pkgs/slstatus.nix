{ pkgs ? import <nixpkgs> { }, configHeader }:

with pkgs; stdenv.mkDerivation rec {
  name = "slstatus";
  src = fetchurl {
    url = https://dl.suckless.org/tools/slstatus-1.0.tar.gz;
    hash = "sha256-bW0KFsCN2dIRFywwxHIHASZ6P0DNyTjbPzhvaits/1Q=";
  };

  buildInputs = [
    xorg.libX11
  ];

  patches = [
    ../patches/slstatus-battery-remaining.diff
    ../patches/slstatus-notify.diff
  ];

  configurePhase = ''
    ln -s ${configHeader} config.h
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

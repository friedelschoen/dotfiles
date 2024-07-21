{ pkgs ? import <nixpkgs> { }, config ? { } }:

with pkgs; stdenv.mkDerivation {
  name = "pretty-svstat";
  src = fetchGit {
    url = "https://git.friedelschoen.io/pretty-svstat";
    rev = "7de4a8b1d49a5c0a72e17794c536d0b3e003bdcf";
  };

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

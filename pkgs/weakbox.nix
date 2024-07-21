{ pkgs ? import <nixpkgs> { }, config ? { } }:

with pkgs; stdenv.mkDerivation rec {
  name = "weakbox";
  src = fetchGit {
    url = "https://git.friedelschoen.io/weakbox";
    rev = "8f7e0468e1fc92e57c8a77f1a49a67846fcce114";
  };

  buildInputs = [ ];

  buildPhase = ''
    make all
  '';

  installPhase = ''
    mkdir -p $out/bin/ $out/share/man/man1/
    make PREFIX=$out install
  '';
}

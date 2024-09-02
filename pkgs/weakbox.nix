{ pkgs
, stdenv
}:

stdenv.mkDerivation rec {
  name = "weakbox";
  src = fetchGit {
    url = "https://git.friedelschoen.io/util/weakbox";
    rev = "8f7e0468e1fc92e57c8a77f1a49a67846fcce114";
  };

  buildPhase = ''
    make all
  '';

  installPhase = ''
    mkdir -p $out/bin/ $out/share/man/man1/
    make PREFIX=$out install
  '';
}

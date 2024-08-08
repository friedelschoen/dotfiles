{ pkgs
, stdenv
}:

stdenv.mkDerivation rec {
  name = "weakbox";
  src = fetchGit {
    url = "https://github.com/friedelschoen/textselect";
    rev = "6131d1ae07f5af71f2df14a5f82a9e64b7ea5ebe";
  };

  buildInputs = with pkgs;  [ ncurses ];

  buildPhase = ''
    make all
  '';

  installPhase = ''
    mkdir -p $out/bin/ $out/share/man/man1/
    make PREFIX=$out install
  '';
}

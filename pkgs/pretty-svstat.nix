{ stdenv
, fetchgit
}:

stdenv.mkDerivation {
  name = "pretty-svstat";
  src = fetchgit {
    url = "https://git.friedelschoen.io/pretty-svstat";
    rev = "7de4a8b1d49a5c0a72e17794c536d0b3e003bdcf";
    hash = "sha256-IVxkvbbWSaP1b1HF3LZHyfUDzXAYy+Vfp7aZzNoVf2Q=";
  };

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

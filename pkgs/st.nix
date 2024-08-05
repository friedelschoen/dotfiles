{ pkgs
, fetchurl
, mkSucklessPackage ? pkgs.callPackage ../common/suckless-pkg.nix { }
,
}:

mkSucklessPackage rec {
  pname = "st";
  version = "0.9.2";

  src = fetchurl {
    url = "https://dl.suckless.org/st/st-${version}.tar.gz";
    hash = "sha256-ayFdT0crIdYjLzDyIRF6d34kvP7miVXd77dCZGf5SUs=";
  };

  configHeader = ../configs/st.h;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs;  [
    fontconfig
    freetype
    xorg.libX11
    xorg.libXft
  ];

  patches = [
    ../patches/st-remove-terminfo.diff
    ../patches/st-scrollback-ringbuffer.diff
    (fetchurl {
      url = https://st.suckless.org/patches/anysize/st-anysize-20220718-baa9357.diff;
      hash = "sha256-eO8MEPRb3uaCTtBznG+LaojXqlcj4eT422rQgpxopfo=";
    })
  ];
}

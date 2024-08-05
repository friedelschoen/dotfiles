{ pkgs
, fetchgit
, mkSucklessPackage ? pkgs.callPackage ../common/suckless-pkg.nix { }
}:

mkSucklessPackage {
  name = "stw";
  src = fetchGit {
    url = "https://github.com/sineemore/stw";
    rev = "54377209c6313c9637aab904d06c5c383414a5ee";
  };

  configHeader = ../configs/stw.h;

  nativeBuildInputs = with pkgs; [
    pkg-config
  ];

  buildInputs = with pkgs; [
    xorg.libXft
    fontconfig
  ];
}

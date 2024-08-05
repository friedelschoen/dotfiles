{ pkgs
, fetchurl
, mkSucklessPackage ? pkgs.callPackage ../common/suckless-pkg.nix { }
}:

mkSucklessPackage {
  name = "slstatus";
  src = fetchurl {
    url = https://dl.suckless.org/tools/slstatus-1.0.tar.gz;
    hash = "sha256-bW0KFsCN2dIRFywwxHIHASZ6P0DNyTjbPzhvaits/1Q=";
  };

  configHeader = ../configs/slstatus.h;

  buildInputs = with pkgs; [
    xorg.libX11
  ];

  patches = [
    ../patches/slstatus-battery-remaining.diff
    ../patches/slstatus-notify.diff
  ];
}

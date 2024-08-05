{ pkgs, fetchurl, mkSucklessPackage ? pkgs.callPackage ../common/suckless-pkg.nix { } }:

mkSucklessPackage {
  name = "tabbed";
  src = fetchurl {
    url = "https://dl.suckless.org/tools/tabbed-0.8.tar.gz";
    hash = "sha256-lb3/zLBxCDBo0rVVwlJOnHxXybZElNRsaX5njUmgo9c=";
  };

  configHeader = ../configs/tabbed.h;
  extraConfig = {
    "theme.h" = pkgs.callPackage ../theme.nix { };
  };

  buildInputs = with pkgs; [
    xorg.libXft
  ];

  patches = [
    ../patches/tabbed-colorscheme.diff
  ];
}

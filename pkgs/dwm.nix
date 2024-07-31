{ pkgs ? import <nixpkgs> { }
, configHeader
}:

pkgs.stdenv.mkDerivation rec {
  name = "dwm";
  src = pkgs.fetchurl {
    url = https://dl.suckless.org/dwm/dwm-6.5.tar.gz;
    hash = "sha256-Ideev6ny+5MUGDbCZmy4H0eExp1k5/GyNS+blwuglyk=";
  };

  buildInputs = with pkgs; [
    xorg.libX11
    xorg.libXft
    xorg.libXinerama
  ];

  patches = [
    # a mix of these patches: statuscolor, statuspadding, systray
    ../patches/dwm-statusbar.diff

    (pkgs.fetchurl {
      url = https://dwm.suckless.org/patches/activetagindicatorbar/dwm-activetagindicatorbar-6.2.diff;
      hash = "sha256-VKqFvR4u+Q6ya+PqaFAuuYfIZb4i3VN2gBTEb564hyA=";
    })
    (pkgs.fetchurl {
      url = https://dwm.suckless.org/patches/urgentborder/dwm-6.2-urg-border.diff;
      hash = "sha256-nPpKIovwTPKdRL6aiWAr6Mt4dXhryvsTw1l00j1QE8w=";
    })
  ];

  configurePhase = ''
    ln -sf ${configHeader} config.h
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

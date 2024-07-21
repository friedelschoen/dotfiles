{ pkgs ? import <nixpkgs> { }
, colors ? [ ]
, borderpx ? 2
, snap ? 10
, horizpadbar ? 10
, vertpadbar ? 10
, showbar ? 1
, topbar ? 1
, systraypinning ? 0
, systrayonleft ? 0
, systrayspacing ? 2
, systraypinningfailfirst ? 1
, showsystray ? 1
, mfact ? 0.6
, nmaster ? 1
, resizehints ? 1
, lockfullscreen ? 1
, fonts ? [ "Source Code Pro:size=9" ]
, tags ? [ "1" "2" "3" "4" "5" ]
, rules ? [ ]
, autostart ? ".dwmrc"
, layouts ? [
    { symbol = "[]="; function = "tile"; }
    { symbol = "{}"; function = "NULL"; }
    { symbol = "[o]"; function = "monocle"; }
  ]
, keys ? [ ]
, buttons ? [ ]
}:

let
  emptyList = [ ];
  lib = pkgs.lib;

  attrValsStringDef = nameList: default: set: map (x: toString set.${x} or default) nameList;
  setToString = names: set: "{ " + (lib.strings.concatStringsSep ", " (attrValsStringDef names "NULL" set)) + " }";

  # 	int i;
  # unsigned int ui;
  # float f;
  # const void *v;


  foldMod = lib.fold builtins.bitOr 0;
  funcArg = value:
    if builtins.isInt value then "{ .i = ${toString value} }"
    else if builtins.isFloat value then "{ .f = ${toString value} }"
    else if builtins.isBool value then "{ .i = ${if value then "1" else "0"} }"
      #else if builtins.isString value then "{ .v = \"${value}\" }"
    else toString value;

  generateConfig = builtins.toFile "config.h" ''
    #include <X11/XF86keysym.h>

    static const unsigned int borderpx  = ${toString borderpx};        /* border pixel of windows */
    static const unsigned int snap      = ${toString snap};       /* snap pixel */
    static const int horizpadbar        = ${toString horizpadbar};        /* horizontal padding for statusbar */
    static const int vertpadbar         = ${toString vertpadbar};        /* vertical padding for statusbar */
    static const int showbar            = ${toString showbar};        /* 0 means no bar */
    static const int topbar             = ${toString topbar};        /* 0 means bottom bar */
    static const unsigned int systraypinning = ${toString systraypinning};   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
    static const unsigned int systrayonleft = ${toString systrayonleft};    /* 0: systray in the right corner, >0: systray on left of status text */
    static const unsigned int systrayspacing = ${toString systrayspacing};   /* systray spacing */
    static const int systraypinningfailfirst = ${toString systraypinningfailfirst};   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
    static const int showsystray        = ${toString showsystray};        /* 0 means no systray */
    static const char *fonts[]          = { ${lib.concatStringsSep ", " (map (f: "\"${f}\"") fonts)} };
    static const float mfact     = ${toString mfact}; /* factor of master area size [0.05..0.95] */
    static const int nmaster     = ${toString nmaster};    /* number of clients in master area */
    static const int resizehints = ${toString resizehints};    /* 1 means respect size hints in tiled resizals */
    static const int lockfullscreen = ${toString lockfullscreen}; /* 1 will force focus on the fullscreen window */
    static const char dwmrc[] = "${autostart}";

    static const char *colors[][3]      = { // light
      /*               fg         bg         border   */
      ${lib.concatStringsSep ",\n" (map (f: "{ \"${f.fg}\", \"${f.bg}\", \"${f.border}\" }") colors)}
    };

    static const char *tags[] = { 
      ${lib.concatStringsSep ", " (map (t: "\"${t}\"") tags)}
    };

    static const Rule rules[] = {
      ${lib.concatMapStringsSep ",\n" (setToString [ "class" "instance" "title" "tags" "isfloating" "monitor" ]) rules}
    };

    static const Layout layouts[] = {
      ${lib.concatStringsSep ",\n" (map (l: "{ \"${l.symbol}\", ${l.function} }") layouts)}
    };

    static const Key keys[] = {
      ${lib.concatMapStringsSep ",\n" (l: "{ ${toString (foldMod (l.mod or emptyList))}, ${l.key}, ${l.func}, ${funcArg (l.arg or "{0}")} }") keys}
    };

    static const Button buttons[] = {
      ${lib.concatMapStringsSep ",\n" (l: "{ ${l.click}, ${toString (foldMod (l.mod or emptyList))}, ${l.button}, ${l.func}, ${funcArg (l.arg or "{0}")} }") buttons}
    };
  '';
in

with pkgs; stdenv.mkDerivation rec {
  name = "dwm";
  src = fetchGit {
    url = "https://git.friedelschoen.io/suckless/dwm";
    rev = "2f0245c39087b0dfce6bb6a1c5269936ab2106b8";
  };

  buildInputs = [
    xorg.libX11
    xorg.libXft
    xorg.libXinerama
  ];

  configurePhase = ''
    cp ${generateConfig} config.h
  '';

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
}

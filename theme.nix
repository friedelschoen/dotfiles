{ lib }:
let
  colors = {
    black = "#282828";
    blue = "#83a598";
    gray2 = "#282828";
    gray3 = "#3c3836";
    gray4 = "#282828";
    green = "#8ec07c";
    orange = "#fe8019";
    pink = "#d3869b";
    red = "#fb4934";
    white = "#ebdbb2";
    yellow = "#b8bb26";
    col_borderbar = "#1e2122";
  };

  header = lib.concatStrings (lib.mapAttrsToList (name: value: "static const char ${name}[] = \"${value}\";\n") colors);
in
builtins.toFile "theme.h" header
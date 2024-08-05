{ lib }:
let

  # Black        | rgb(40, 44, 52)    | #282c34 |
  # " | White        | rgb(171, 178, 191) | #abb2bf |
  # " | Light Red    | rgb(224, 108, 117) | #e06c75 |
  # " | Dark Red     | rgb(190, 80, 70)   | #be5046 |
  # " | Green        | rgb(152, 195, 121) | #98c379 |
  # " | Light Yellow | rgb(229, 192, 123) | #e5c07b |
  # " | Dark Yellow  | rgb(209, 154, 102) | #d19a66 |
  # " | Blue         | rgb(97, 175, 239)  | #61afef |
  # " | Magenta      | rgb(198, 120, 221) | #c678dd |
  # " | Cyan         | rgb(86, 182, 194)  | #56b6c2 |
  # " | Gutter Grey  | rgb(76, 82, 99)    | #4b5263 |
  # " | Comment Grey | rgb(92, 99, 112)   | #5c6370 |

  colors = {
    black = "#282c34";
    blue = "#61afef";
    gray2 = "#4b5263";
    gray3 = "#5c6370";
    gray4 = "#4b5263";
    green = "#98c379";
    orange = "#d19a66";
    pink = "#e06c75";
    red = "#be5046";
    white = "#abb2bf";
    yellow = "#e5c07b";
    magenta = "#c678dd";
    cyan = "#56b6c2";
  };

  #251d3a, #2a2550, #e04d01 and #ff7700.

  header = lib.concatStrings (lib.mapAttrsToList (name: value: "static const char ${name}[] = \"${value}\";\n") colors);
in
builtins.toFile "theme.h" header

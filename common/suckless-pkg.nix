{ stdenv, lib }:

{ configHeader ? null, extraConfig ? { }, ... }@args:

let
  configs = extraConfig // (lib.optionalAttrs (configHeader != null) { "config.h" = configHeader; });
  configurePhase = lib.concatStrings (lib.mapAttrsToList (dest: src: "ln -sfv ${src} ${dest}\n") configs);
in
stdenv.mkDerivation (
  (builtins.removeAttrs args [ "configHeader" "extraConfig" ]) // {

  inherit configurePhase;

  buildPhase = ''
    make all
  '';

  installPhase = ''
    make PREFIX=$out install
  '';
})
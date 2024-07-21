{ pkgs ? import <nixpkgs> { }, system ? builtins.currentSystem }:


{ name, services, supervise }:
with pkgs; let
  createSupervise = writeScript "${name}-create-supervise" ''
    #!/bin/sh

    # create tmp/supervise.<service> (or whatever is specified)
    mkdir -p ${lib.strings.concatStringsSep " " (map (sv: supervise sv.name) services)}
  '';

  linkDir = sv: ''
    # create out/<service> (later ./)
    mkdir -p $out/${sv.name}

    # change dir to ./out/<service>
    cd $out/${sv.name}

    # ./supervise ./run are mandatory, thus just unconditional linking
    ln -s ${supervise sv.name} ./supervise 
    ln -s ${sv.run} ./run 

    # if ./setup is specified (not empty), link it
    [ -n '${sv.setup}' ] && ln -s ${sv.setup} $out/${sv.name}/setup || true

    # if not enabled, create empty file ./down
    [ '${toString sv.enable}' = 'false' ] && touch $out/${sv.name}/down || true
  '';
  linkDirs = lib.strings.concatStrings (map linkDir services);

in
runCommand name { } ''
  #!/bin/sh

  mkdir -p $out
  ln -s ${createSupervise} $out/create-supervise.sh
    
  ${linkDirs}
''

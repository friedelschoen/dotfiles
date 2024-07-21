{ pkgs ? import <nixpkgs> { } }:

{
  dmenu = pkgs.callPackage ./dmenu.nix { };
  dwm = pkgs.callPackage ./dwm.nix { };
  pretty-svstat = pkgs.callPackage ./pretty-svstat.nix { };
  slstatus = pkgs.callPackage ./slstatus.nix { };
  st = pkgs.callPackage ./st.nix { };
  void-runit = pkgs.callPackage ./void-runit.nix { };
  weakbox = pkgs.callPackage ./weakbox.nix { };

  make-service = import ./make-service.nix { inherit pkgs; };
}

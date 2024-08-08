{ pkgs
, stdenv
, fetchzip
}:

stdenv.mkDerivation rec {
  name = "runit-utils";
  version = "20231124";

  src = fetchzip {
    url = "https://github.com/void-linux/void-runit/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-XGQcRaaGntAx4HFLTLZRjMGcejtJyJQEF/yXfQmzrZs=";
  };

  installPhase = ''
    install -d $out/bin
    install -m755 halt $out/bin
    install -m755 pause $out/bin
    install -m755 vlogger $out/bin
    install -m755 shutdown $out/bin/shutdown
    install -m755 modules-load $out/bin/modules-load
    install -m755 seedrng $out/bin/seedrng
    install -m755 zzz $out/bin
    ln -sf zzz $out/bin/ZZZ
    ln -sf halt $out/bin/poweroff
    ln -sf halt $out/bin/reboot
    install -d $out/share/man/man1
    install -m644 pause.1 $out/share/man/man1
    install -d $out/share/man/man8
    install -m644 zzz.8 $out/share/man/man8
    install -m644 shutdown.8 $out/share/man/man8
    install -m644 halt.8 $out/share/man/man8
    install -m644 modules-load.8 $out/share/man/man8
    install -m644 vlogger.8 $out/share/man/man8
    ln -sf halt.8 $out/share/man/man8/poweroff.8
    ln -sf halt.8 $out/share/man/man8/reboot.8
  '';
}

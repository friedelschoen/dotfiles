{ pkgs ? import <nixpkgs> { } }:

with pkgs; [
  {
    name = "9wm";
    enable = false;
    setup = "";
    run = writeScript "9wm-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1

      cd $HOMEs
      exec 9wm
    '';
  }
  {
    name = "blueman-applet";
    enable = true;
    setup = "";
    run = writeScript "blueman-applet-run" ''
      #!/bin/sh


      SVDIR=.. sv check xserver > /dev/null || exit 1

      exec blueman-applet
    '';
  }
  {
    name = "dbus-session";
    enable = true;
    setup = "";
    run = writeScript "dbus-session-run" ''
      #!/bin/sh

      exec dbus-daemon --nofork --session
    '';
  }
  {
    name = "dwm";
    enable = true;
    setup = "";
    run = writeScript "dwm-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1

      cd $HOME
      exec dwm
    '';
  }
  {
    name = "nm-applet";
    enable = true;
    setup = "";
    run = writeScript "nm-applet-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1

      exec nm-applet
    '';
  }
  {
    name = "pa-applet";
    enable = true;
    setup = "";
    run = writeScript "pa-applet-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1

      exec pa-applet
    '';
  }
  {
    name = "slstatus";
    enable = true;
    setup = "";
    run = writeScript "slstatus-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1

      FIFO=/tmp/slstatus.fifo

      [ -p $FIFO ] || rm -f $FIFO
      mkfifo $FIFO

      exec slstatus -p $FIFO 
    '';
  }
  {
    name = "slstatus-xbps";
    enable = true;
    setup = "";
    run = writeScript "slstatus-xbps-run" ''
      #!/bin/bash

      OUTPUT=/tmp/xbps-updates.txt

      while true; do
          updates=$(xbps-install -Mun | wc -l)

          if [ $updates -ne 0 ]; then
              echo $updates > $OUTPUT
          else
              echo up-to-date > $OUTPUT
          fi
          sleep 120
      done
    '';
  }
  {
    name = "stw-service";
    enable = true;
    setup = "";
    run = writeScript "stw-service-run" ''
      #!/bin/sh

      exec stw -p 1 -b '#ebdbb2' -f '#3c3836' -F 'Source Code Pro:size=9' -B 10 -y 20 sh -c 'echo -- services -- ; psv /var/service/* ~/.xservice/* 2> /dev/null | sort -k2,2 -k1,1'
    '';
  }
  {
    name = "stw-xbps";
    enable = true;
    setup = "";
    run = writeScript "stw-xbps-run" ''
      #!/bin/sh

      exec stw -b '#ebdbb2' -f '#3c3836' -F 'Source Code Pro:size=9' -B 10 -p 120 -y 100% -Y -100% sh -c 'echo -- updates -- && xbps-install -Mun | cut -d" " -f1'
    '';
  }
  {
    name = "tiramisu";
    enable = true;
    setup = "";
    run = writeScript "tiramisu-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1
      SVDIR=.. sv check slstatus > /dev/null || exit 1

      exec tiramisu -o '\\x04#source\\x05#summary: #body\\n' | xargs -i printf '%b' '{}' > /tmp/slstatus.fifo
    '';
  }
  {
    name = "xfce-polkit";
    enable = true;
    setup = "";
    run = writeScript "xfce-polkit-run" ''
      #!/bin/sh

      SVDIR=.. sv check xserver > /dev/null || exit 1

      exec /usr/libexec/xfce-polkit
    '';
  }
  {
    name = "xserver";
    enable = true;
    setup = "";
    run = writeScript "xserver-run" ''
      #!/bin/sh

      if [ -z "$XDG_VTNR" ]; then
          exec X -nolisten tcp $DISPLAY
      else
          exec X -nolisten tcp $DISPLAY vt$XDG_VTNR
      fi
    '';
  }
]

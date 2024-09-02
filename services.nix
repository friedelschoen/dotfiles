{ writeScript, ... }:


let
  stw-background = "#4d4d4d";
  stw-foreground = "#eeeeee";
  stw-font = "Monaco:size=9";

in [
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

      exec nm-applet
    '';
  }
  {
    name = "pa-applet";
    enable = true;
    setup = "";
    run = writeScript "pa-applet-run" ''
      #!/bin/sh

      exec pa-applet
    '';
  }
  {
    name = "battery-applet";
    enable = true;
    setup = "";
    run = writeScript "battery-applet-run" ''
      #!/bin/sh

      exec cbatticon
    '';
  }
  {
    name = "slstatus";
    enable = true;
    setup = "";
    run = writeScript "slstatus-run" ''
      #!/bin/sh

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

      exec stw -b '${stw-background}' -f '${stw-foreground}' -F '${stw-font}' -p 1 -B 10 -y 20 sh -c 'echo -- services -- ; psv /var/service/* ~/.xservice/* 2> /dev/null | sort -k2,2 -k1,1'
    '';
  }
  {
    name = "stw-xbps";
    enable = true;
    setup = "";
    run = writeScript "stw-xbps-run" ''
      #!/bin/sh

      exec stw -b '${stw-background}' -f '${stw-foreground}' -F '${stw-font}' -B 10 -p 120 -y 100% -Y -100% sh -c 'echo -- updates -- && xbps-install -Mun | cut -d" " -f1'
    '';
  }
  {
    name = "tiramisu";
    enable = true;
    setup = "";
    run = writeScript "tiramisu-run" ''
      #!/bin/sh

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

      exec /usr/libexec/xfce-polkit
    '';
  }
]

{ config, pkgs, fetchgit, ... }:

let
  localpkgs = import ./pkgs { inherit pkgs; };
  bitor = builtins.bitOr;

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
  };

  colorscheme = with colors; [
    { bg = gray3; fg = white; border = gray2; }
    { bg = gray3; fg = blue; border = blue; }
    { bg = gray3; fg = orange; border = red; }
    { bg = gray3; fg = orange; border = gray2; }
    { bg = gray3; fg = green; border = gray2; }
  ];

  dwm_util = rec {
    mask = {
      shift = 1;
      lock = 2;
      control = 4;
      mod1 = 8;
      mod2 = 16;
      mod3 = 32;
      mod4 = 64;
      mod5 = 128;
    };

    modkey = mask.mod4;
    tagkeys = { tag, key }: [
      { mod = [ modkey ];                         inherit key; func = "view"; arg = "{.ui = 1 << ${toString tag}}"; }
      { mod = [ modkey mask.control ];            inherit key; func = "toggleview"; arg = "{.ui = 1 << ${toString tag}}"; }
      { mod = [ modkey mask.shift ];              inherit key; func = "tag"; arg = "{.ui = 1 << ${toString tag}}"; }
      { mod = [ modkey mask.control mask.shift ]; inherit key; func = "toggletag"; arg = "{.ui = 1 << ${toString tag}}"; }
    ];

    shell = cmd: "{ .v = (const char*[]){ \"/bin/sh\", \"-c\", \"${cmd}\", NULL } }";
    command = cmd: "{ .v = (const char*[]){ ${pkgs.lib.strings.concatMapStrings (w: "\"${w}\",") cmd} NULL } }";
    backlight = device: value: command [ "brightnessctl" "-q" "-d" device "set" value ];

    monitor_backlight = "acpi_video0";
    keyboard_backlight = "smc::kbd_backlight";
  };
in
rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "friedel";
  home.homeDirectory = "/home/friedel";

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with localpkgs; [
    (dwm.override (with dwm_util; {
      borderpx = 3;
      snap = 15;
      horizpadbar = 5;
      vertpadbar = 5;
      showbar = 1;
      topbar = 1;
      systraypinning = 0;
      systrayonleft = 0;
      systrayspacing = 2;
      systraypinningfailfirst = 1;
      showsystray = 1;
      fonts = [ "Monaco:size=10" ];
      tags = [ "1" "2" "3" "4" "5" ];
      autostart = "./dwmrc";
      colors = colorscheme;
      rules = [
        { class = "\"Firefox\""; tags = "1 << 5"; isfloating = 0; monitor = -1; }
      ];
      layouts = [
        { symbol = "[]="; function = "tile"; }
        { symbol = "{}"; function = "NULL"; }
        { symbol = "[o]"; function = "monocle"; }
      ];
      keys = [
        { mod = [ modkey ]; key = "XK_Return"; func = "spawn"; arg = command [ "st" ]; }
        { mod = [ modkey mask.shift ]; key = "XK_w"; func = "spawn"; arg = command [ "surf" ]; }
        { mod = [ modkey ]; key = "XK_w"; func = "spawn"; arg = command [ "firefox" ]; }
        { mod = [ modkey ]; key = "XK_space"; func = "spawn"; arg = command [ "dmenu_run" "-c" "-bh" "5" "-l" "20" "-g" "2" ]; }
        { mod = [ modkey ]; key = "XK_m"; func = "spawn"; arg = shell "man -k . | dmenu -c -l 25 | cut -d' ' -f1-2 | sed -E 's/(\S+) \((\S+)\)/\2 \1/' | xargs st -f 'SF Mono' -e man -s"; }
        { key = "XF86XK_MonBrightnessUp"; func = "spawn"; arg = backlight monitor_backlight "+5%"; }
        { key = "XF86XK_MonBrightnessDown"; func = "spawn"; arg = backlight monitor_backlight "5%-"; }
        { key = "XF86XK_KbdBrightnessUp"; func = "spawn"; arg = backlight keyboard_backlight "+5%"; }
        { key = "XF86XK_KbdBrightnessDown"; func = "spawn"; arg = backlight keyboard_backlight "5%-"; }
        { mod = [ modkey ]; key = "XK_o"; func = "spawn"; arg = command [ "dfm" ]; }
        { mod = [ modkey mask.shift ]; key = "XK_o"; func = "spawn"; arg = command [ "dfm" "-c" ]; }
        { mod = [ modkey ]; key = "XK_b"; func = "togglebar"; }
        { mod = [ modkey ]; key = "XK_j"; func = "focusstack"; arg = 1; }
        { mod = [ modkey ]; key = "XK_k"; func = "focusstack"; arg = -1; }
        { mod = [ modkey ]; key = "XK_i"; func = "incnmaster"; arg = 1; }
        { mod = [ modkey ]; key = "XK_d"; func = "incnmaster"; arg = -1; }
        { mod = [ modkey ]; key = "XK_Left"; func = "setmfact"; arg = -0.05; }
        { mod = [ modkey ]; key = "XK_Right"; func = "setmfact"; arg = 0.05; }
        { mod = [ modkey mask.shift ]; key = "XK_Return"; func = "zoom"; }
        { mod = [ modkey ]; key = "XK_Tab"; func = "view"; }
        { mod = [ modkey ]; key = "XK_q"; func = "killclient"; }
        { mod = [ modkey mask.control ]; key = "XK_comma"; func = "cyclelayout"; arg = -1; }
        { mod = [ modkey mask.control ]; key = "XK_period"; func = "cyclelayout"; arg = 1; }
        { mod = [ modkey mask.control ]; key = "XK_space"; func = "setlayout"; }
        { mod = [ modkey mask.shift ]; key = "XK_space"; func = "togglefloating"; }
        { mod = [ modkey ]; key = "XK_0"; func = "view"; arg = "{.ui = ~0 }"; }
        { mod = [ modkey mask.shift ]; key = "XK_0"; func = "tag"; arg = "{.ui = ~0 }"; }
        { mod = [ modkey ]; key = "XK_comma"; func = "focusmon"; arg = -1; }
        { mod = [ modkey ]; key = "XK_period"; func = "focusmon"; arg = 1; }
        { mod = [ modkey mask.shift ]; key = "XK_comma"; func = "tagmon"; arg = -1; }
        { mod = [ modkey mask.shift ]; key = "XK_period"; func = "tagmon"; arg = 1; }
        { mod = [ modkey mask.shift ]; key = "XK_r"; func = "refresh"; }
        { mod = [ modkey mask.shift ]; key = "XK_q"; func = "quit"; }
      ]
      ++ (tagkeys { tag = 0; key = "XK_1"; })
      ++ (tagkeys { tag = 1; key = "XK_2"; })
      ++ (tagkeys { tag = 2; key = "XK_3"; })
      ++ (tagkeys { tag = 3; key = "XK_4"; })
      ++ (tagkeys { tag = 4; key = "XK_5"; });
      buttons = [
        { button = "Button1"; click = "ClkLtSymbol"; func = "cyclelayout"; arg = 1; }
        { button = "Button2"; click = "ClkWinTitle"; func = "zoom"; }
        { button = "Button2"; click = "ClkStatusText"; func = "spawn"; arg = command [ "st" ]; }
        { mod = [ modkey ]; button = "Button1"; click = "ClkClientWin"; func = "movemouse"; }
        { mod = [ modkey ]; button = "Button2"; click = "ClkClientWin"; func = "togglefloating"; }
        { mod = [ modkey ]; button = "Button3"; click = "ClkClientWin"; func = "resizemouse"; }
        { button = "Button1"; click = "ClkTagBar"; func = "view"; }
        { button = "Button3"; click = "ClkTagBar"; func = "toggleview"; }
        { mod = [ modkey ]; button = "Button1"; click = "ClkTagBar"; func = "tag"; }
        { mod = [ modkey ]; button = "Button3"; click = "ClkTagBar"; func = "toggletag"; }
      ];
    }))
    (dmenu.override { colors = colorscheme; })
    pretty-svstat
    slstatus
    st
    void-runit
    weakbox

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" "FiraCode" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".xservice".source = localpkgs.make-service rec {
      name = "home-service";
      services = import ./services.nix { inherit pkgs; };
      supervise = sv: "/tmp/${name}/supervise.${sv}";
    };

    ".dwmrc".source = ./dotfiles/dwmrc;
    ".xinitrc".source = ./dotfiles/xinitrc;
  };

  home.sessionVariables = {
    PLAN9 = "${pkgs.plan9port}";
    WEAKBOX = "$HOME/.glibc";
    EDITOR = "vim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.nix-index.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ls = "${pkgs.eza}/bin/eza";
      clip = "${pkgs.xclip}/bin/xclip -selection clipboard";
      neofetch = "${pkgs.fastfetch}/bin/fastfetch";
      ccat = "${pkgs.bat}/bin/bat --style=plain --paging=never --theme=OneHalfDark";
    };

    history = {
      size = 10000;
      path = "${config.xdg.dataHome}/zsh/history";
    };

    initExtra = ''
      source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        
      vsv() {
        if [ "$UID" -eq 0 ]; then
          dir=/var/service
        else
          dir=$HOME/.xservice
        fi
        /usr/bin/vsv -d $dir $@
      }

      export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$PLAN9/bin"
      export MANPATH="$MANPATH:$HOME/.local/share/man:$PLAN9/man"

      if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
        startx
      fi   
    '';
  };

  programs.vim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-one
      vim-airline
      vim-airline-themes
      auto-pairs
      vim-auto-save
      ale
    ];
    settings = {
      background = "dark";
      number = true;
      tabstop = 4;
      shiftwidth = 4;
      relativenumber = true;
    };
    extraConfig = builtins.readFile ./dotfiles/vimrc;
  };


  home.stateVersion = "24.05"; # Please read the comment before changing.
}

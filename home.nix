{ config, pkgs, fetchgit, ... }:

rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "friedel"; # EDIT ME
  home.homeDirectory = "/home/friedel"; # EDIT ME

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    (pkgs.callPackage pkgs/dmenu.nix { })
    (pkgs.callPackage pkgs/dwm.nix { })
    (pkgs.callPackage pkgs/pretty-svstat.nix { })
    (pkgs.callPackage pkgs/slstatus.nix { })
    (pkgs.callPackage pkgs/st.nix { })
    (pkgs.callPackage pkgs/void-runit.nix { })
    (pkgs.callPackage pkgs/weakbox.nix { })
    (pkgs.callPackage pkgs/stw.nix { })
    (pkgs.callPackage pkgs/tabbed.nix { })
    (pkgs.callPackage pkgs/surf.nix { })

    # use nix' nix, it is more up-to-date
    pkgs.nix

    pkgs.nixpkgs-fmt

    (pkgs.nerdfonts.override { fonts = [ "CascadiaCode" "FiraCode" ]; })
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".xservice".source = (import common/make-service.nix { }) rec {
      name = "home-service";
      services = import ./services.nix { inherit pkgs; };
      supervise = sv: "/tmp/${name}/supervise.${sv}";
    };

    ".xinitrc".source = dotfiles/xinitrc;
    ".Xresources".source = dotfiles/xresources;
    "home-manager".source = ./.;
  };

  home.sessionVariables = {
    EDITOR = "vim";
    PLAN9 = "${pkgs.plan9port}/plan9";
    WEAKBOX = "$HOME/.glibc";
    HOMEMANAGER = ./.;
  };

  nix = {
    package = pkgs.nix;
    # settings.experimental-features = [ "nix-command" "flakes" "impure-derivations" ];

    extraOptions = "experimental-features = nix-command flakes impure-derivations";
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
      hm = "home-manager";
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
    extraConfig = builtins.readFile dotfiles/vimrc;
  };

  targets.genericLinux.enable = true;

  home.stateVersion = "24.05"; # Please read the comment before changing.
}

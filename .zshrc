#!/bin/zsh

plugins=(zsh-autosuggestions zsh-syntax-highlighting)

for pl in $plugins; do
	source /usr/share/zsh/plugins/$pl/$pl.plugin.zsh
done

vsv() {
	[ "$UID" -eq 0 ] && export SVDIR=/var/service || export SVDIR=$HOME/.xservice
	/usr/bin/vsv $@
}


alias ls="exa"
alias clip="xclip -selection clipboard"
alias neofetch="fastfetch"

export PLAN9="$HOME/plan9port"
export PATH="$PATH:$HOME/.local/bin:$PLAN9/bin"
export MANPATH="$MANPATH:$HOME/.local/share/man:$PLAN9/man"
export WEAKBOX="$HOME/.glibc"

# if we are a tty1, 
if [ -z "$DISPLAY" -a `tty` = "/dev/tty1" ]; then
	exec ~/.xinitrc
fi

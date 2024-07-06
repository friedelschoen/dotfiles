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
alias ccat="bat --style=plain --paging=never --theme=OneHalfDark"

export PLAN9="$HOME/plan9port"
export PATH="$PATH:$HOME/.local/bin:$HOME/.cargo/bin:$PLAN9/bin"
export MANPATH="$MANPATH:$HOME/.local/share/man:$PLAN9/man"
export WEAKBOX="$HOME/.glibc"

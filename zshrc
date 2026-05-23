# === Options ===

setopt prompt_subst
setopt auto_cd
setopt interactive_comments
setopt hist_ignore_dups
setopt hist_ignore_space
setopt share_history
setopt inc_append_history

HISTFILE="$HOME/.zsh_history"
HISTSIZE=100000
SAVEHIST=100000

# === Completion ===

autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' verbose yes

source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# === Keybindings ===

bindkey -e

# Ctrl-left / Ctrl-right
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word
bindkey '^[[5D' backward-word
bindkey '^[[5C' forward-word

bindkey "^[[3~" delete-char

# === Environment ===

export PLAN9="$HOME/git/9fans/plan9port"
export NAMESPACE="/tmp/ns.friedel.:0"
export EDITOR="nvim"
export ELECTRON_OZONE_PLATFORM_HINT="wayland"
export DOTNET_ROOT="$HOME/dotnet"
export QT_QPA_PLATFORM="wayland"
export PSVDIRS="/var/service:$HOME/.config/service"
export PAGER="nvimpager"

mkdir -p "$NAMESPACE"

path=(
    $path
    "$HOME/.local/bin"
    "$HOME/dotnet"
    "$HOME/go/bin"
    "$HOME/opt/segger-jlink"
    "$PLAN9/bin"
    "$HOME/.yarn/bin"
)

export PATH

export MANPATH="$(manpath -q):$HOME/.local/share/man:$PLAN9/man"

# Rust/Cargo
[ -r "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# === Aliases ===

alias ls="exa"
alias xo="xdg-open"
alias clip="xclip -selection clipboard"
alias neofetch="fastfetch"
alias ccat="chroma -s github"
alias code-oss="code-oss --no-sandbox"
alias vsv-user="vsv -d ~/.xservice"
alias JLink="JLinkExe"
alias acme="acme -f $PLAN9/font/monaco/monaco.12.font"
alias deadcode='deadcode -f="{{println .Path}}{{range .Funcs}}{{printf \"\t%s\t%s\n\" .Name .Position}}{{end}}{{println}}"'

mkdir -p /tmp/downloads

# === Prompt ===

autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats ' %F{blue}(%b)%f'
zstyle ':vcs_info:git:*' actionformats ' %F{blue}(%b|%a)%f'

precmd() {
    local exitcode=$?

    vcs_info

    local status_part=""
    if (( exitcode != 0 )); then
        status_part="%B%F{red}${exitcode}%f%b | "
    fi

    PROMPT="${status_part}%B%F{magenta}%m%f%b %~%f${vcs_info_msg_0_}>%f "
}

source $HOME/.cargo/env

# === Desktop Environment ===

if [[ -z "$DISPLAY" && "$(tty)" = "/dev/tty1" ]]; then
    exec dbus-run-session sway
fi

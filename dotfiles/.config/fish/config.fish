# === FUNCTIONS ===

function fish_prompt
    set -l time $CMD_DURATION
    set -l time_unit ms
    set -l old_status $status

    if [ $time -ge 1000 ]
        set time (math --scale=1 $time / 1000)
        set time_unit s
        if [ $time -ge 60 ]
            set time (math --scale=1 $time / 60)
            set time_unit min
        end
    end

    set_color brgreen
    echo -n $time$time_unit" "

    if [ "$old_status" != 0 ]
        set_color -o brred
        echo -n "[exit with $old_status] "
    end

    set_color normal
    echo -n '| '

    set_color -o brmagenta
    echo -n (hostname)
    echo -n " "

    set_color $fish_color_cwd
    echo -n (prompt_pwd)
    set_color brblue
    fish_vcs_prompt
    set_color normal
    echo -n '> '
end

function fish_greeting
end

source "$HOME/.cargo/env.fish"

# === Environment ===

set -x PLAN9 $HOME/git/9fans/plan9port
set -x NAMESPACE "/tmp/ns.friedel.:0"
set -x EDITOR "micro"

mkdir -p $NAMESPACE

set -xa PATH $HOME/.local/bin
set -xa PATH $HOME/go/bin
set -xa PATH $HOME/opt/segger-jlink
set -xa PATH $PLAN9/bin

set -xa MANPATH (manpath -q) "$HOME/.local/share/man" "$PLAN9/man"

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

# === TODO's ===

mkdir -p /tmp/downloads # <- symlinked to $home/downloads

# === Desktop Environment ===

if [ -z "$DISPLAY" -a (tty) = /dev/tty1 ]
    exec dbus-run-session sway
end

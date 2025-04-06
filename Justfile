list:
    @just --list

build:
    bake dotfiles.json

install:
    rm -r ~/.dotfiles
    cp -Lr result ~/.dotfiles
    stow -v -d ~/.dotfiles .
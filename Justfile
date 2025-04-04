list:
    @just --list

build:
    bake/bake dotfiles.json

stow:
    stow -v result
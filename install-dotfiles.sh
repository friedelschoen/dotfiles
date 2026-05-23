#!/bin/sh

case "$1" in
    "remove")
        unlink -v ~/.icons
        unlink -v ~/.zshrc
        ;;
    "install")
    "")
        ln -sv .config/icons ~/.icons
        ln -sv .config/zshrc ~/.zshrc
        ;;
esac

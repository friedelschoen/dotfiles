#!/bin/sh

# set keyboard
setxkbmap -layout us -variant intl

# set background
xsetroot -solid '#282c34'

# set security
xhost +si:localuser:$USER

# get resources config
xrdb $HOME/.Xresources

$HOME/.xservice/create-supervise.sh
exec runsvdir $HOME/.xservice

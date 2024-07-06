#!/bin/sh

export DISPLAY=:0
export XAUTHORITY=$HOME/.Xauthority
export XSERVICELOG=$HOME/.xservice.log/current

mv $XSERVICELOG $XSERVICELOG.old

exec runsvdir $HOME/.xservice

#!/bin/sh

awk -v out=$1 '/\s*#/ {next} $2 == out { print $1 " " $3; exit 0 } END { exit 1 }' sources.txt | {
    read uri hash
    echo hash $hash
    echo uri $uri
} || exit 1
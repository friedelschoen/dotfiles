#!/bin/bash

pkgs=$(xbps-install -Mun | cut -d' ' -f1)

if [ -z "$pkgs" ]; then
    text="0"
    tooltip="System up to date"
    class="uptodate"
else
    text=$(printf '%s\n' "$pkgs" | wc -l)
    tooltip=$(printf '%s' "$pkgs" | awk '{printf "%s\\n", $0}')
    class="outdated"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}' \
  "$text" "$tooltip" "$class"


#!/bin/bash

text=$(psvstat -c)
tooltip="<small><tt>$(psvstat -s)</tt></small>"

exec jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text: $text, tooltip: $tooltip}'


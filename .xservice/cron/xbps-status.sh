#!/bin/bash

OUTPUT=/tmp/xbps-updates.txt

#tr -dc A-Za-z0-9 < /dev/urandom | head -c 5 > $OUTPUT
#exit

echo "checking updates..." >&2

updates=$(xbps-install -Mun | wc -l)

if [ $updates -ne 0 ]; then 
	echo $updates > $OUTPUT
else
	echo up-to-date > $OUTPUT
fi


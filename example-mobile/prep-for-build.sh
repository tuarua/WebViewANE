#!/bin/sh

echo "Cleaning files for build:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

if [ ! -d "$pathtome/bin-release/device" ]; then
rm -r "$pathtome/platforms/bin-release/device"
fi

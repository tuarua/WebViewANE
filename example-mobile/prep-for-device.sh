#!/bin/sh

echo "Preparing files for iOS Packaging tool:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

if [ ! -d "$pathtome/bin-release/device/assets" ]; then
mkdir "$pathtome/bin-release/device/assets"
fi

cp -R -L "$pathtome/bin-release/device/Default-375w-667h@2x.png" "$pathtome/bin-release/device/assets/Default-375w-667h@2x.png"
rm -r "$pathtome/bin-release/device/Default-375w-667h@2x.png"

cp -R -L "$pathtome/bin-release/device/Default-568h@2x.png" "$pathtome/bin-release/device/assets/Default-568h@2x.png"
rm -r "$pathtome/bin-release/device/Default-568h@2x.png"

cp -R -L "$pathtome/bin-release/device/Default-Portrait.png" "$pathtome/bin-release/device/assets/Default-Portrait.png"
rm -r "$pathtome/bin-release/device/Default-Portrait.png"

cp -R -L "$pathtome/bin-release/device/Default.png" "$pathtome/bin-release/device/assets/Default.png"
rm -r "$pathtome/bin-release/device/Default.png"

cp -R -L "$pathtome/bin-release/device/Default@2x.png" "$pathtome/bin-release/device/assets/Default@2x.png"
rm -r "$pathtome/bin-release/device/Default@2x.png"

cp -R -L "$pathtome/bin-release/device/icon57.png" "$pathtome/bin-release/device/assets/icon57.png"
rm -r "$pathtome/bin-release/device/icon57.png"

cp -R -L "$pathtome/bin-release/device/icon72.png" "$pathtome/bin-release/device/assets/icon72.png"
rm -r "$pathtome/bin-release/device/icon72.png"

cp -R -L "$pathtome/bin-release/device/icon114.png" "$pathtome/bin-release/device/assets/icon114.png"
rm -r "$pathtome/bin-release/device/icon114.png"

cp -R -L "$pathtome/bin-release/device/icon144.png" "$pathtome/bin-release/device/assets/icon144.png"
rm -r "$pathtome/bin-release/device/icon144.png"

cp -R -L "$pathtome/bin-release/device/jsTest.html" "$pathtome/bin-release/device/assets/jsTest.html"
rm -r "$pathtome/bin-release/device/jsTest.html"

cp -R -L "$pathtome/bin-release/device/localTest.html" "$pathtome/bin-release/device/assets/localTest.html"
rm -r "$pathtome/bin-release/device/localTest.html"

if [ ! -d "$pathtome/bin-release/device/assets/textures" ]; then
mkdir "$pathtome/bin-release/device/assets/textures"
fi

mv "$pathtome/bin-release/device/textures/" "$pathtome/bin-release/device/assets/"

#rm -r "$pathtome/platforms/ios/default"

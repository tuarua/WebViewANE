#!/bin/sh

AneVersion="2.6.0"
FreSwiftVersion="3.1.0"

rm -r ios_dependencies/device
rm -r ios_dependencies/simulator

wget https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/ios_dependencies.zip
unzip -u ios_dependencies.zip
rm ios_dependencies.zip

wget https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/ios_dependencies.zip
unzip -u -o ios_dependencies.zip
rm ios_dependencies.zip

wget -O ../native_extension/ane/WebViewANE.ane https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/WebViewANE.ane?raw=true

#!/bin/sh

AneVersion="1.8.1"
FreSwiftVersion="2.5.0"

wget -O ../native_extension/ane/CommonDependencies.ane https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/CommonDependencies.ane?raw=true
wget -O ../native_extension/ane/WebViewANE.ane https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/WebViewANE.ane?raw=true

#!/bin/sh

AneVersion="2.5.0"
FreSwiftVersion="3.1.0"
FreSharpVersion="2.2.0"

wget -O ../native_extension/ane/FreSwift.ane https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/FreSwift.ane?raw=true
wget -O ../native_extension/ane/WebViewANE.ane https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/WebViewANE.ane?raw=true
wget -O ../native_extension/ane/FreSharp.ane https://github.com/tuarua/FreSharp/releases/download/$FreSharpVersion/FreSharp.ane?raw=true

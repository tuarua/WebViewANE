$AneVersion = "1.9.1"

$currentDir = (Get-Item -Path ".\" -Verbose).FullName
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://github.com/tuarua/Swift-IOS-ANE/releases/download/2.5.0/CommonDependencies.ane?raw=true -OutFile "$currentDir\..\native_extension/ane/CommonDependencies.ane"
Invoke-WebRequest -Uri https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/WebViewANE.ane?raw=true -OutFile "$currentDir\..\native_extension\ane\WebViewANE.ane"
Invoke-WebRequest -Uri https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/cef_binaries_x86.zip?raw=true -OutFile "$currentDir\..\cef_binaries_x86.zip"
Invoke-WebRequest -Uri https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/cef_binaries_x64.zip?raw=true -OutFile "$currentDir\..\cef_binaries_x64.zip"
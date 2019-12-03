$AneVersion = "2.9.0"
$FreSharpVersion = "2.3.0"
$FreSwiftVersion = "4.1.0"

$currentDir = (Get-Item -Path ".\" -Verbose).FullName
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://github.com/tuarua/Swift-IOS-ANE/releases/download/$FreSwiftVersion/FreSwift.ane?raw=true -OutFile "$currentDir\..\native_extension\ane\FreSwift.ane"
Invoke-WebRequest -Uri https://github.com/tuarua/WebViewANE/releases/download/$AneVersion/WebViewANE.ane?raw=true -OutFile "$currentDir\..\native_extension\ane\WebViewANE.ane"
Invoke-WebRequest -Uri https://github.com/tuarua/FreSharp/releases/download/$FreSharpVersion/FreSharp.ane?raw=true -OutFile "$currentDir\..\native_extension\ane\FreSharp.ane"
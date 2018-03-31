$currentDir = (Get-Item -Path ".\" -Verbose).FullName
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri https://github.com/tuarua/Swift-IOS-ANE/releases/download/2.4.0/CommonDependencies.ane?raw=true -OutFile "$currentDir\..\native_extension/ane/CommonDependencies.ane"

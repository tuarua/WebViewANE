$currentDir = (Get-Item -Path ".\" -Verbose).FullName

Invoke-WebRequest -Uri https://github.com/tuarua/Swift-OSX-ANE/releases/download/2.1.0/CommonDependencies.ane?raw=true -OutFile "$currentDir\..\native_extension/ane/CommonDependencies.ane"

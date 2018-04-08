$currentDir = (Get-Item -Path ".\" -Verbose).FullName
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -OutFile "$currentDir\android_dependencies\com.tuarua.frekotlin.ane" -Uri https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/kotlin/com.tuarua.frekotlin.ane?raw=true
Invoke-WebRequest -Uri https://github.com/tuarua/WebViewANE/releases/download/1.6.0/WebViewANE.ane?raw=true -OutFile "$currentDir\..\native_extension\ane\WebViewANE.ane"
$currentDir = (Get-Item -Path ".\" -Verbose).FullName
Invoke-WebRequest -OutFile "$currentDir\..\native_extension\ane\mobile\com.tuarua.frekotlin.ane" -Uri https://github.com/tuarua/Android-ANE-Dependencies/blob/master/anes/kotlin/com.tuarua.frekotlin.ane?raw=true

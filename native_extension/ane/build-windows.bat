REM Get the path to the script and trim to get the directory.
@echo off
SET SZIP="C:\Program Files\7-Zip\7z.exe"
SET AIR_PATH="D:\dev\sdks\AIR\AIRSDK_25\bin\"
echo Setting path to current directory to:
SET pathtome=%~dp0
echo %pathtome%

SET projectName=WebViewANE

REM Setup the directory.
echo Making directories.

IF NOT EXIST %pathtome%platforms mkdir %pathtome%platforms
IF NOT EXIST %pathtome%platforms\win  %pathtome%platforms\win
IF NOT EXIST %pathtome%platforms\win\release mkdir %pathtome%platforms\win\release
IF NOT EXIST %pathtome%platforms\win\debug mkdir %pathtome%platforms\win\debug

REM Copy SWC into place.
echo Copying SWC into place.
echo %pathtome%..\bin\%projectName%.swc
copy %pathtome%..\bin\%projectName%.swc %pathtome%

REM contents of SWC.
echo Extracting files form SWC.
echo %pathtome%%projectName%.swc
copy %pathtome%%projectName%.swc %pathtome%%projectName%Extract.swc
ren %pathtome%%projectName%Extract.swc %projectName%Extract.zip

call %SZIP% e %pathtome%%projectName%Extract.zip -o%pathtome%

del %pathtome%%projectName%Extract.zip

REM Copy library.swf to folders.
echo Copying library.swf into place.
copy %pathtome%library.swf %pathtome%platforms\win\release
copy %pathtome%library.swf %pathtome%platforms\win\debug


REM Copy native libraries into place.
echo Copying native libraries into place.

copy %pathtome%..\..\native_library\win\%projectName%\Release\%projectName%.dll %pathtome%platforms\win\release
copy %pathtome%..\..\native_library\win\%projectName%\Debug\%projectName%.dll %pathtome%platforms\win\debug

copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Debug\CefSharpLib.dll %AIR_PATH%CefSharpLib.dll
copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Debug\CefSharpLib.pdb %AIR_PATH%CefSharpLib.pdb

copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Release\CefSharpLib.dll %pathtome%..\..\cef_sharp_libs\CefSharpLib.dll

copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Debug\FreSharpCore.dll %AIR_PATH%FreSharpCore.dll
copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Debug\FreSharpCore.pdb %AIR_PATH%FreSharpCore.pdb

copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Debug\FreSharp.dll %AIR_PATH%FreSharp.dll
copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Debug\FreSharp.pdb %AIR_PATH%FreSharp.pdb

copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Release\FreSharpCore.dll %pathtome%..\..\cef_sharp_libs\FreSharpCore.dll
copy %pathtome%..\..\native_library\win\%projectName%\CefSharpLib\CefSharpLib\bin\x86\Release\FreSharp.dll %pathtome%..\..\cef_sharp_libs\FreSharp.dll

REM Run the build command.
echo Building Release.
call %AIR_PATH%adt.bat -package -target ane %pathtome%%projectName%.ane %pathtome%extension_win.xml -swc %pathtome%%projectName%.swc -platform Windows-x86 -C %pathtome%platforms\win\release %projectName%.dll library.swf
echo Building Debug
call %AIR_PATH%adt.bat -package -target ane %pathtome%%projectName%-debug.ane %pathtome%extension_win.xml -swc %pathtome%%projectName%.swc -platform Windows-x86 -C %pathtome%platforms\win\debug %projectName%.dll library.swf

call %SZIP% x %pathtome%%projectName%-debug.ane -o%pathtome%debug\%projectName%.ane\ -aoa

call DEL /F /Q /A %pathtome%%projectName%-debug.ane
call DEL /F /Q /A %pathtome%%projectName%.swc
call DEL /F /Q /A %pathtome%library.swf
call DEL /F /Q /A %pathtome%catalog.xml

echo FIN

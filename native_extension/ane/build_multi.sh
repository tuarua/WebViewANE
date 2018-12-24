#!/bin/sh

#Get the path to the script and trim to get the directory.
pathtome=$0
pathtome="${pathtome%/*}"

PROJECTNAME=WebViewANE
fwSuffix="_FW"
libSuffix="_LIB"

AIR_SDK="/Users/eoinlandy/SDKs/AIRSDK_32"
echo $AIR_SDK

if [ ! -d "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release-iphonesimulator/" ]; then
echo "No Simulator build. Build using Xcode"
exit
fi

if [ ! -d "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release-iphoneos/" ]; then
echo "No Device build. Build using Xcode"
exit
fi

if [ ! -d "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release/" ]; then
echo "No OSX build. Build using Xcode"
exit
fi

#Setup the directory.
echo "Making directories."

if [ ! -d "$pathtome/platforms" ]; then
mkdir "$pathtome/platforms"
fi
if [ -d "$pathtome/platforms/mac" ]; then
rm -r "$pathtome/platforms/mac"
fi
if [ ! -d "$pathtome/platforms/mac" ]; then
mkdir "$pathtome/platforms/mac"
mkdir "$pathtome/platforms/mac/release"
fi
if [ ! -d "$pathtome/platforms/ios" ]; then
mkdir "$pathtome/platforms/ios"
fi
if [ ! -d "$pathtome/platforms/ios/simulator" ]; then
mkdir "$pathtome/platforms/ios/simulator"
fi
if [ ! -d "$pathtome/platforms/ios/simulator/Frameworks" ]; then
mkdir "$pathtome/platforms/ios/simulator/Frameworks"
fi
if [ ! -d "$pathtome/platforms/ios/device" ]; then
mkdir "$pathtome/platforms/ios/device"
fi
if [ ! -d "$pathtome/platforms/ios/device/Frameworks" ]; then
mkdir "$pathtome/platforms/ios/device/Frameworks"
fi
if [ ! -d "$pathtome/platforms/default" ]; then
mkdir "$pathtome/platforms/default"
fi


#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/$PROJECTNAME.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/$PROJECTNAME.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/mac/release"
cp "$pathtome/library.swf" "$pathtome/platforms/win/x86/release"
cp "$pathtome/library.swf" "$pathtome/platforms/win/x64/release"
cp "$pathtome/library.swf" "$pathtome/platforms/ios/simulator"
cp "$pathtome/library.swf" "$pathtome/platforms/ios/device"
cp "$pathtome/library.swf" "$pathtome/platforms/android"
cp "$pathtome/library.swf" "$pathtome/platforms/default"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release/$PROJECTNAME.framework" "$pathtome/platforms/mac/release"
rm -r "$pathtome/platforms/mac/release/$PROJECTNAME.framework/Versions"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release-iphonesimulator/lib$PROJECTNAME$libSuffix.a" "$pathtome/platforms/ios/simulator/lib$PROJECTNAME.a"
cp -R -L "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release-iphoneos/lib$PROJECTNAME$libSuffix.a" "$pathtome/platforms/ios/device/lib$PROJECTNAME.a"


cp -R -L "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks/FreSwift.framework" "$pathtome/platforms/ios/simulator/Frameworks"
cp -R -L "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks/FreSwift.framework" "$pathtome/platforms/ios/device/Frameworks"


cp -R -L "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release-iphonesimulator/$PROJECTNAME$fwSuffix.framework" "$pathtome/platforms/ios/simulator/Frameworks"
cp -R -L "$pathtome/../../native_library/apple/$PROJECTNAME/Build/Release-iphoneos/$PROJECTNAME$fwSuffix.framework" "$pathtome/platforms/ios/device/Frameworks"


echo "COPYING Android aars into place"
cp "$pathtome/../../native_library/android/$PROJECTNAME/app/build/outputs/aar/app-release.aar" "$pathtome/platforms/android/app-release.aar"

echo "getting Android jars"
unzip "$pathtome/platforms/android/app-release.aar" "classes.jar" -d "$pathtome/platforms/android"
unzip "$pathtome/platforms/android/app-release.aar" "res/*" -d "$pathtome/platforms/android"
mv "$pathtome/platforms/android/res" "$pathtome/platforms/android/com.tuarua.$PROJECTNAME-res"


#move the swift dylibs into root of "$pathtome/platforms/ios/ios_dependencies/Frameworks" as per Adobe docs for AIR27

echo "Copying Swift dylibs into place for device."
#Device
if [ -e "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]
then
for dylib in "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks/*"
do
mv -f $dylib "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks"
done
rm -r "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks"
fi

echo "Copying Swift dylibs into place for simulator."
#Simulator
if [ -e "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]
then
for dylib in "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks/*"
do
mv -f $dylib "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks"
done
if [ -d "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]; then
rm -r "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks"
fi
fi

if [ -f "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib"
fi
if [ -f "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib"
fi
if [ -f "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib"
fi
if [ -f "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib"
fi

cp -R -L "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework" "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks"
cp -R -L "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework" "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks"


#Run the build command.
echo "Building ANE."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/$PROJECTNAME.ane" "$pathtome/extension_multi.xml" \
-swc "$pathtome/$PROJECTNAME.swc" \
-platform Android-ARM \
-C "$pathtome/platforms/android" "library.swf" "classes.jar" \
com.tuarua.$PROJECTNAME-res/. \
-platformoptions "$pathtome/platforms/android/platform.xml" \
-platform Android-x86 \
-C "$pathtome/platforms/android" "library.swf" "classes.jar" \
com.tuarua.$PROJECTNAME-res/. \
-platformoptions "$pathtome/platforms/android/platform.xml" \
-platform iPhone-x86  -C "$pathtome/platforms/ios/simulator" "library.swf" "Frameworks" "lib$PROJECTNAME.a" \
-platformoptions "$pathtome/platforms/ios/platform.xml" \
-platform iPhone-ARM  -C "$pathtome/platforms/ios/device" "library.swf" "Frameworks" "lib$PROJECTNAME.a" \
-platformoptions "$pathtome/platforms/ios/platform.xml" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/release" "$PROJECTNAME.framework" "library.swf" \
-platform Windows-x86 -C "$pathtome/platforms/win/x86/release" "$PROJECTNAME.dll" "library.swf" \
-platform Windows-x86-64 -C "$pathtome/platforms/win/x64/release" "$PROJECTNAME.dll" "library.swf" \
-platform default -C "$pathtome/platforms/default" "library.swf"

#remove the frameworks from sim and device, as not needed any more
rm "$pathtome/platforms/android/classes.jar"
rm "$pathtome/platforms/android/app-release.aar"
rm "$pathtome/platforms/android/library.swf"
rm -r "$pathtome/platforms/ios/simulator"
rm -r "$pathtome/platforms/ios/device"
rm -r "$pathtome/platforms/default"
rm "$pathtome/$PROJECTNAME.swc"
rm "$pathtome/library.swf"
rm -r "$pathtome/platforms/android/com.tuarua.$PROJECTNAME-res"

echo "Packaging docs into ANE."
zip "$pathtome/$PROJECTNAME.ane" -u docs/*

echo "Finished."

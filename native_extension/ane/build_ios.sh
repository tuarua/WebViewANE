#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"

PROJECTNAME=WebViewANE
fwSuffix="_FW"
libSuffix="_LIB"

AIR_SDK="/Users/eoinlandy/SDKs/AIRSDK_33"
echo ${AIR_SDK}

if [ ! -d "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/" ]; then
echo "No Simulator build. Build using Xcode"
exit
fi

if [ ! -d "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/" ]; then
echo "No Device build. Build using Xcode"
exit
fi

#Setup the directory.
echo "Making directories."

if [ ! -d "$pathtome/platforms" ]; then
mkdir "$pathtome/platforms"
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
cp "$pathtome/library.swf" "$pathtome/platforms/ios/simulator"
cp "$pathtome/library.swf" "$pathtome/platforms/ios/device"
cp "$pathtome/library.swf" "$pathtome/platforms/default"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/lib$PROJECTNAME$libSuffix.a" "$pathtome/platforms/ios/simulator/lib$PROJECTNAME.a"
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/lib$PROJECTNAME$libSuffix.a" "$pathtome/platforms/ios/device/lib$PROJECTNAME.a"

cp -R -L "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks/FreSwift.framework" "$pathtome/platforms/ios/simulator/Frameworks"
cp -R -L "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks/FreSwift.framework" "$pathtome/platforms/ios/device/Frameworks"

cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/$PROJECTNAME$fwSuffix.framework" "$pathtome/platforms/ios/simulator/Frameworks"
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/$PROJECTNAME$fwSuffix.framework" "$pathtome/platforms/ios/device/Frameworks"


#move the swift dylibs into root of "$pathtome/platforms/ios/ios_dependencies/Frameworks" as per Adobe docs for AIR27

echo "Copying Swift dylibs into place for device."
#Device
if [ -e "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]
then
for dylib in "$pathtome"/platforms/ios/device/Frameworks/"$PROJECTNAME""$fwSuffix".framework/Frameworks/*
do
mv -f "$dylib" "$pathtome/../../example-mobile/ios_dependencies/device/Frameworks"
done
rm -r "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks"
fi

echo "Copying Swift dylibs into place for simulator."
#Simulator
if [ -e "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]
then
for dylib in "$pathtome"/platforms/ios/simulator/Frameworks/"$PROJECTNAME""$fwSuffix".framework/Frameworks/*
do
mv -f "$dylib" "$pathtome/../../example-mobile/ios_dependencies/simulator/Frameworks"
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
-target ane "$pathtome/mobile/$PROJECTNAME.ane" "$pathtome/extension_ios.xml" \
-swc "$pathtome/$PROJECTNAME.swc" \
-platform iPhone-x86  -C "$pathtome/platforms/ios/simulator" "library.swf" "Frameworks" "lib$PROJECTNAME.a" \
-platformoptions "$pathtome/platforms/ios/platform.xml" \
-platform iPhone-ARM  -C "$pathtome/platforms/ios/device" "library.swf" "Frameworks" "lib$PROJECTNAME.a" \
-platformoptions "$pathtome/platforms/ios/platform.xml" \
-platform default -C "$pathtome/platforms/default" "library.swf"

#remove the frameworks from sim and device, as not needed any more
rm -r "$pathtome/platforms/ios/simulator"
rm -r "$pathtome/platforms/ios/device"
rm -r "$pathtome/platforms/default"
rm "$pathtome/$PROJECTNAME.swc"
rm "$pathtome/library.swf"
echo "Finished."

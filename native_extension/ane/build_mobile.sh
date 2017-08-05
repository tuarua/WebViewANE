#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"


echo "Setting up directories"

PROJECTNAME=WebViewANE
fwSuffix="_FW"
libSuffix="_LIB"

AIR_SDK="/Users/User/sdks/AIR/AIRSDK_27_B"

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
if [ ! -d "$pathtome/platforms/android" ]; then
mkdir "$pathtome/platforms/android"
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
cp "$pathtome/library.swf" "$pathtome/platforms/android"

#Copy ios native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/lib$PROJECTNAME$libSuffix.a" "$pathtome/platforms/ios/simulator/lib$PROJECTNAME.a"
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/lib$PROJECTNAME$libSuffix.a" "$pathtome/platforms/ios/device/lib$PROJECTNAME.a"

#cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/FreSwift/FreSwift-iOS-Swift.h" "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/FreSwift.framework/Headers/FreSwift-iOS-Swift.h"
#cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/FreSwift/FreSwift-iOS-Swift.h" "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/FreSwift.framework/Headers/FreSwift-iOS-Swift.h"
#cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/FreSwift/FreSwift-iOS-Swift.h" "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Debug-iphonesimulator/FreSwift.framework/Headers/FreSwift-iOS-Swift.h"
#cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/FreSwift/FreSwift-iOS-Swift.h" "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Debug-iphoneos/FreSwift.framework/Headers/FreSwift-iOS-Swift.h"


cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/FreSwift.framework" "$pathtome/platforms/ios/simulator/Frameworks"
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/FreSwift.framework" "$pathtome/platforms/ios/device/Frameworks"

cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphonesimulator/$PROJECTNAME$fwSuffix.framework" "$pathtome/platforms/ios/simulator/Frameworks"
cp -R -L "$pathtome/../../native_library/ios/$PROJECTNAME/Build/Products/Release-iphoneos/$PROJECTNAME$fwSuffix.framework" "$pathtome/platforms/ios/device/Frameworks"

#Copy android native libraries into place.

echo "COPYING Android aars into place"
cp "$pathtome/../../native_library/android/$PROJECTNAME/app/build/outputs/aar/app-release.aar" "$pathtome/platforms/android/app-release.aar"

echo "getting Android jars"
unzip "$pathtome/platforms/android/app-release.aar" "classes.jar" -d "$pathtome/platforms/android"



#Run the build command.
echo "Generating ANE."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/mobile/$PROJECTNAME-mobile.ane" "$pathtome/extension_mobile.xml" \
-swc "$pathtome/$PROJECTNAME.swc" \
-platform Android-ARM \
-C "$pathtome/platforms/android" "library.swf" "classes.jar" \
-platformoptions "$pathtome/platforms/android/platform.xml" "res/values/strings.xml" \
-platform Android-x86 \
-C "$pathtome/platforms/android" "library.swf" "classes.jar" \
-platformoptions "$pathtome/platforms/android/platform.xml" "res/values/strings.xml" \
-platform iPhone-x86  -C "$pathtome/platforms/ios/simulator" "library.swf" "Frameworks" "lib$PROJECTNAME.a" \
-platformoptions "$pathtome/platforms/ios/platform.xml" \
-platform iPhone-ARM  -C "$pathtome/platforms/ios/device" "library.swf" "Frameworks" "lib$PROJECTNAME.a" \
-platformoptions "$pathtome/platforms/ios/platform.xml" \
-platform default -C "$pathtome/platforms/default" "library.swf"


#create folders if they don't exist
if [ ! -d "$pathtome/../../example-mobile/native" ]; then
mkdir "$pathtome/../../example-mobile/native"
fi
if [ ! -d "$pathtome/../../example-mobile/native/device" ]; then
mkdir "$pathtome/../../example-mobile/native/device"
fi
if [ ! -d "$pathtome/../../example-mobile/native/device/Frameworks" ]; then
mkdir "$pathtome/../../example-mobile/native/device/Frameworks"
fi
if [ ! -d "$pathtome/../../example-mobile/native/simulator" ]; then
mkdir "$pathtome/../../example-mobile/native/simulator"
fi
if [ ! -d "$pathtome/../../example-mobile/native/simulator/Frameworks" ]; then
mkdir "$pathtome/../../example-mobile/native/simulator/Frameworks"
fi

#copy frameworks folder to src
cp -R -L "$pathtome/platforms/ios/device/Frameworks/FreSwift.framework" "$pathtome/../../example-mobile/native/device/Frameworks"
cp -R -L "$pathtome/platforms/ios/device/Frameworks/$PROJECTNAME$fwSuffix.framework" "$pathtome/../../example-mobile/native/device/Frameworks"
cp -R -L "$pathtome/platforms/ios/simulator/Frameworks/FreSwift.framework" "$pathtome/../../example-mobile/native/simulator/Frameworks"
cp -R -L "$pathtome/platforms/ios/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework" "$pathtome/../../example-mobile/native/simulator/Frameworks"

#remove the frameworks from sim and device, as not needed any more
rm -r "$pathtome/platforms/ios/simulator"
rm -r "$pathtome/platforms/ios/device"


rm -r "$pathtome/platforms/default"
rm "$pathtome/$PROJECTNAME.swc"
rm "$pathtome/library.swf"
rm "$pathtome/platforms/android/library.swf"
rm "$pathtome/platforms/android/classes.jar"

#cd $pathtome
zip "$pathtome/mobile/$PROJECTNAME-mobile.ane" -u docs/*

#move the swift dylibs into root of "$pathtome/platforms/ios/device/Frameworks" as per Adobe docs for AIR27
#Device

#FreSwift
if [ -e "$pathtome/../../example-mobile/native/device/Frameworks/FreSwift.framework/Frameworks" ]
then
for dylib in "$pathtome/../../example-mobile/native/device/Frameworks/FreSwift.framework/Frameworks/*"
do
mv -f $dylib "$pathtome/../../example-mobile/native/device/Frameworks"
done
rm -r "$pathtome/../../example-mobile/native/device/Frameworks/FreSwift.framework/Frameworks"
fi
if [ -f "$pathtome/../../example-mobile/native/device/Frameworks/FreSwift.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/../../example-mobile/native/device/Frameworks/FreSwift.framework/libswiftRemoteMirror.dylib"
fi
#Project
if [ -e "$pathtome/../../example-mobile/native/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]
then
for dylib in "$pathtome/../../example-mobile/native/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks/*"
do
mv -f $dylib "$pathtome/../../example-mobile/native/device/Frameworks"
done
rm -r "$pathtome/../../example-mobile/native/device/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks"
fi
if [ -f "$pathtome/../../examexample-mobileple/native/device/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/../../example-mobile/native/device/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib"
fi

#Simulator

if [ -e "$pathtome/../../example-mobile/native/simulator/Frameworks/FreSwift.framework/Frameworks" ]
then
for dylib in "$pathtome/../../example-mobile/native/simulator/Frameworks/FreSwift.framework/Frameworks/*"
do
mv -f $dylib "$pathtome/../../example-mobile/native/simulator/Frameworks"
done
rm -r "$pathtome/../../example-mobile/native/simulator/Frameworks/FreSwift.framework/Frameworks"
fi
if [ -f "$pathtome/../../example-mobile/native/simulator/Frameworks/FreSwift.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/../../example-mobile/native/simulator/Frameworks/FreSwift.framework/libswiftRemoteMirror.dylib"
fi

if [ -e "$pathtome/../../example-mobile/native/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks" ]
then
for dylib in "$pathtome/../../example-mobile/native/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks/*"
do
mv -f $dylib "$pathtome/../../example-mobile/native/simulator/Frameworks"
done
rm -r "$pathtome/../../example-mobile/native/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/Frameworks"
fi
if [ -f "$pathtome/../../example-mobile/native/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib" ]; then
rm "$pathtome/../../example-mobile/native/simulator/Frameworks/$PROJECTNAME$fwSuffix.framework/libswiftRemoteMirror.dylib"
fi


#!/bin/sh

#Get the path to the script and trim to get the directory.
echo "Setting path to current directory to:"
pathtome=$0
pathtome="${pathtome%/*}"
echo $pathtome

PROJECT_NAME=WebViewANE

AIR_SDK="/Users/User/sdks/AIR/AIRSDK_27"
echo $AIR_SDK

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


#Copy SWC into place.
echo "Copying SWC into place."
cp "$pathtome/../bin/$PROJECT_NAME.swc" "$pathtome/"

#Extract contents of SWC.
echo "Extracting files form SWC."
unzip "$pathtome/$PROJECT_NAME.swc" "library.swf" -d "$pathtome"

#Copy library.swf to folders.
echo "Copying library.swf into place."
cp "$pathtome/library.swf" "$pathtome/platforms/mac/release"
cp "$pathtome/library.swf" "$pathtome/platforms/win/x86/release"
cp "$pathtome/library.swf" "$pathtome/platforms/win/x64/release"

#Copy native libraries into place.
echo "Copying native libraries into place."
cp -R -L "$pathtome/../../native_library/mac/$PROJECT_NAME/$PROJECT_NAME/$PROJECT_NAME-Swift.h" "$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Release/$PROJECT_NAME.framework/Versions/A/Headers/$PROJECT_NAME-Swift.h"
cp -R -L "$pathtome/../../native_library/mac/$PROJECT_NAME/$PROJECT_NAME/$PROJECT_NAME-Swift.h" "$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Debug/$PROJECT_NAME.framework/Versions/A/Headers/$PROJECT_NAME-Swift.h"

cp -R -L "$pathtome/../../native_library/mac/$PROJECT_NAME/Build/Products/Release/$PROJECT_NAME.framework" "$pathtome/platforms/mac/release"

rm -r "$pathtome/platforms/mac/release/$PROJECT_NAME.framework/Versions"


#Run the build command.
echo "Building Release."
"$AIR_SDK"/bin/adt -package \
-target ane "$pathtome/$PROJECT_NAME.ane" "$pathtome/extension_multi.xml" \
-swc "$pathtome/$PROJECT_NAME.swc" \
-platform MacOS-x86-64 -C "$pathtome/platforms/mac/release" "$PROJECT_NAME.framework" "library.swf" \
-platform Windows-x86 -C "$pathtome/platforms/win/x86/release" "$PROJECT_NAME.dll" "library.swf" \
-platform Windows-x86-64 -C "$pathtome/platforms/win/x64/release" "$PROJECT_NAME.dll" "library.swf" \
-platform default -C "$pathtome" "library.swf"


rm "$pathtome/$PROJECT_NAME.swc"
rm "$pathtome/library.swf"

echo "Packaging docs into ANE."
zip "$pathtome/$PROJECT_NAME.ane" -u docs/*
echo "DONE!"

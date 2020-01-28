#!/bin/bash

# Code Signature invalid error is expected if you try and run your store app on your mac without uploading it.
# See https://developer.apple.com/library/archive/qa/qa1884/_index.html

# Name of your app.
APP="Main"
TEAM_ID="XXXXXXXX"

# See https://developer.apple.com/documentation/bundleresources/information_property_list/lsapplicationcategorytype
APP_CATEGORY="public.app-category.games"

# Certificates and signing.
APP_KEY="3rd Party Mac Developer Application: Xxxx Xxxx (XXXXXXXX)"
INSTALLER_KEY="3rd Party Mac Developer Installer: Xxxx Xxxx (XXXXXXXX)"
PROVISION_PROFILE="AppStoreDeveloper.provisionprofile"

# from https://appleid.apple.com/#!&page=signin  > Security > APP-SPECIFIC PASSWORDS > Generate password…
TWO_FAC_UN="USER_NAME"
TWO_FAC_PW="PASSWORD"

############################################################################################################
############################################################################################################
############################################################################################################

red=$'\e[1;31m'
grn=$'\e[1;32m'
blu=$'\e[1;34m'
mag=$'\e[1;35m'
cyn=$'\e[1;36m'
white=$'\e[0m'
PlistBuddy=/usr/libexec/PlistBuddy
pathtome=$0
pathtome="${pathtome%/*}"
cd "$pathtome"

echo ${cyn} "Check Tools Availability" ${white}

if [ ! -d "$(xcrun --show-sdk-path)" ]
then
    echo ${red} "Xcode not configured" ${white}
    exit 72
fi

if [ ! -x "${PlistBuddy}" ]
then
    echo ${red} "Couldn't find PlistBuddy" ${white}
    exit 72
fi

if [ ! -f "$pathtome/$PROVISION_PROFILE" ]; then
    echo ${red} "Can't find $PROVISION_PROFILE. Did you forget to copy it into the packaging folder?" ${white}
    exit 72
fi

echo ${cyn} "Copying $APP.app" ${white}

if [ ! -d "$pathtome/../bin-release/$APP.app" ]; then
    echo ${red} "Can't find bin-release/$APP.app. Package your AIR app!" ${white}
    exit 72
fi

if [ -d "$APP.app" ]; then
    rm -r "$APP.app"
fi

xattr -cr "../bin-release/$APP.app"
cp -R "../bin-release/$APP.app" "$pathtome/"

BUNDLE_ID=$( "${PlistBuddy}" -c "Print CFBundleIdentifier" "$APP.app/Contents/Info.plist" )
APP_VERSION=$( "${PlistBuddy}" -c "Print CFBundleShortVersionString" "$APP.app/Contents/Info.plist" )

echo ${cyn} "Making icons..." ${white}

if [ ! -f "$pathtome/icon-1024.png" ]; then
    echo ${red} "Can't find icon-1024.png. Create a 1024x1024 png." ${white}
    exit
fi

sips -z 16 16     icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_16x16.png > /dev/null 2>&1
sips -z 32 32     icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_16x16@2x.png > /dev/null 2>&1
sips -z 32 32     icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_32x32.png > /dev/null 2>&1
sips -z 64 64     icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_32x32@2x.png > /dev/null 2>&1
sips -z 128 128   icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_128x128.png > /dev/null 2>&1
sips -z 256 256   icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_128x128@2x.png > /dev/null 2>&1
sips -z 256 256   icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_256x256.png > /dev/null 2>&1
sips -z 512 512   icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_256x256@2x.png > /dev/null 2>&1
sips -z 512 512   icon-1024.png --out Assets.xcassets/AppIcon.appiconset/icon_512x512.png > /dev/null 2>&1
cp icon-1024.png Assets.xcassets/AppIcon.appiconset/icon_512x512@2x.png
mkdir build
xcrun actool Assets.xcassets --compile build --platform macosx --minimum-deployment-target 10.10 --app-icon AppIcon --output-partial-info-plist build/partial.plist > /dev/null 2>&1
cp -R "build/AppIcon.icns" "$APP.app/Contents/Resources"
cp -R "build/Assets.car" "$APP.app/Contents/Resources"
rm -R "build"

echo ${cyn} "Cleaning up unneeded AIR files" ${white}

xattr -cr "$APP.app"
rm -r "$APP.app/Contents/Frameworks/Adobe AIR.framework/Versions/1.0/Resources/Adobe AIR.vch"
rm -r "$APP.app/Contents/Frameworks/Adobe AIR.framework/Versions/1.0/Resources/WebKit.dylib"
rm -r "$APP.app/Contents/Frameworks/Adobe AIR.framework/Versions/1.0/Resources/Flash Player.plugin"
rm -r "$APP.app/Contents/Frameworks/Adobe AIR.framework/Versions/1.0/Resources/WebKit"
rm -r "$APP.app/Contents/Frameworks/Adobe AIR.framework/Versions/1.0/Resources/__MACOSX"
rm -r "$APP.app/Contents/Frameworks/Adobe AIR.framework/Versions/1.0/Resources/A2712Enabler"
xattr -cr $APP.app

echo ${cyn} "Fixing Info.plist entries" ${white}

$PlistBuddy -c "Add :LSApplicationCategoryType string $APP_CATEGORY" $APP.app/Contents/Info.plist
$PlistBuddy -c "Add :CFBundleVersion string $APP_VERSION" $APP.app/Contents/Info.plist
$PlistBuddy -c "Add :CFBundleIconName string AppIcon" $APP.app/Contents/Info.plist
$PlistBuddy -c "Add :CFBundleIconFile string AppIcon" $APP.app/Contents/Info.plist
$PlistBuddy -c "Add :CFBundleSupportedPlatforms array" $APP.app/Contents/Info.plist
$PlistBuddy -c "Add :CFBundleSupportedPlatforms: string MacOSX" $APP.app/Contents/Info.plist
# Swift requires 10.10 not AIR's 10.6
$PlistBuddy -c "Set :LSMinimumSystemVersion 10.10" $APP.app/Contents/Info.plist

echo ${cyn} "Correct ANE symlinks" ${white}
if [ -d "$APP.app/Contents/Resources/META-INF/AIR/extensions" ]; then
    cd $APP.app/Contents/Resources/META-INF/AIR/extensions
    for ane in *
    do
    IFS='.' read -ra my_array <<< "$ane"
    LEN=${#my_array[@]}
    LAST=$(( $LEN - 1 ))
    ANE_NAME="${my_array[LAST]}"

    if [ -d "${ane}/META-INF/ANE/MacOS-x86-64/${ANE_NAME}.framework" ]; then
        # https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPFrameworks/Concepts/FrameworkAnatomy.html
        cd "${ane}/META-INF/ANE/MacOS-x86-64/${ANE_NAME}.framework"
        mkdir Versions
        cd Versions
        mkdir A
        cd ../
        if [ -d Frameworks ]; then
            mv Frameworks Versions/A
        fi
        mv $ANE_NAME Versions/A
        mv Modules Versions/A
        mv Headers Versions/A
        mv Resources Versions/A
        cd Versions
        ln -s A Current
        cd ../
        ln -s Versions/Current/$ANE_NAME $ANE_NAME
        ln -s Versions/Current/Resources Resources
        ln -s Versions/Current/Headers Headers
        ln -s Versions/Current/Modules Modules
        cd "../../../../../"
    fi
    done
fi
cd "$pathtome"

echo ${cyn} "Applying values to Entitlements" ${white}

ROOT_ENTITLEMENTS="Root.entitlements"
CHILD_ENTITLEMENTS="Child.entitlements"

val=$($PlistBuddy -c 'print ":com.apple.developer.team-identifier"' $ROOT_ENTITLEMENTS 2>/dev/null)
exitCode=$?
if (( exitCode == 0 )); then
    $PlistBuddy -c "Set :com.apple.developer.team-identifier $TEAM_ID" $ROOT_ENTITLEMENTS
fi

val=$($PlistBuddy -c 'print ":com.apple.application-identifier"' $ROOT_ENTITLEMENTS 2>/dev/null)
exitCode=$?
if (( exitCode == 0 )); then
    $PlistBuddy -c "Set :com.apple.application-identifier $TEAM_ID.$BUNDLE_ID" $ROOT_ENTITLEMENTS
fi

val=$($PlistBuddy -c 'print ":com.apple.security.application-groups"' $ROOT_ENTITLEMENTS 2>/dev/null)
exitCode=$?
if (( exitCode == 0 )); then
    $PlistBuddy -c "Set :com.apple.security.application-groups:0 $TEAM_ID.$BUNDLE_ID" $ROOT_ENTITLEMENTS
fi

echo ${cyn} "Embedding Provisioning Profile" ${white}

cp -R $PROVISION_PROFILE "$APP.app/Contents/embedded.provisionprofile"

echo ${cyn} "Signing..." ${white}

xcrun codesign -f -s "$APP_KEY" --deep --entitlements "$CHILD_ENTITLEMENTS" --options runtime --timestamp $APP.app/Contents/Frameworks/* > /dev/null 2>&1
codesign_result=$?
if [ "${codesign_result}" != "0" ]; then
    echo ${red} "Failed to sign AIR Framework: ${codesign_result}" ${white}
    exit 1
fi
if [ -d "$APP.app/Contents/Resources/META-INF/AIR/extensions" ]; then
    cd $APP.app/Contents/Resources/META-INF/AIR/extensions
    for ane in *
    do
    IFS='.' read -ra my_array <<< "$ane"
    LEN=${#my_array[@]}
    LAST=$(( $LEN - 1 ))
    ANE_NAME="${my_array[LAST]}"
    if [ -d "${ane}/META-INF/ANE/MacOS-x86-64/${ANE_NAME}.framework" ]; then
        xcrun codesign -f -s "$APP_KEY" --deep --entitlements "$pathtome/$CHILD_ENTITLEMENTS" --options runtime --timestamp ${ane}/META-INF/ANE/MacOS-x86-64/${ANE_NAME}.framework > /dev/null 2>&1
        codesign_result=$?
        if [ "${codesign_result}" != "0" ]; then
            echo ${red} "Failed to sign ANE: ${codesign_result}" ${white}
            exit 1
        fi
    fi
    done
    cd "$pathtome"
fi
xcrun codesign -f -s "$APP_KEY" --entitlements "$ROOT_ENTITLEMENTS" --options runtime --timestamp $APP.app
codesign_result=$?
if [ "${codesign_result}" != "0" ]; then
    echo ${red} "Failed to sign main App binary: ${codesign_result}" ${white}
    exit 1
fi

val=$($PlistBuddy -c 'print ":com.apple.developer.team-identifier"' $ROOT_ENTITLEMENTS 2>/dev/null)
exitCode=$?
if (( exitCode == 0 )); then
    $PlistBuddy -c "Set :com.apple.developer.team-identifier XXX" $ROOT_ENTITLEMENTS
fi

val=$($PlistBuddy -c 'print ":com.apple.application-identifier"' $ROOT_ENTITLEMENTS 2>/dev/null)
exitCode=$?
if (( exitCode == 0 )); then
    $PlistBuddy -c "Set :com.apple.application-identifier XXX.x.x.x" $ROOT_ENTITLEMENTS
fi

val=$($PlistBuddy -c 'print ":com.apple.security.application-groups"' $ROOT_ENTITLEMENTS 2>/dev/null)
exitCode=$?
if (( exitCode == 0 )); then
    $PlistBuddy -c "Set :com.apple.security.application-groups:0 XXX.x.x.x" $ROOT_ENTITLEMENTS
fi

echo ${cyn} "Verify codesign" ${white}

xcrun codesign -vvv --deep --strict $APP.app > /dev/null 2>&1
codesign_result=$?
if [ "${codesign_result}" != "0" ]; then
    echo ${red} "Failed to sign App: ${codesign_result}" ${white}
    exit 1
fi
if [ -d "$APP.app/Contents/Resources/META-INF/AIR/extensions" ]; then
    cd $APP.app/Contents/Resources/META-INF/AIR/extensions
    for ane in *
    do
    IFS='.' read -ra my_array <<< "$ane"
    LEN=${#my_array[@]}
    LAST=$(( $LEN - 1 ))
    ANE_NAME="${my_array[LAST]}"
    if [ -d "${ane}/META-INF/ANE/MacOS-x86-64/${ANE_NAME}.framework" ]; then
        xcrun codesign -vvv --deep --strict ${ane}/META-INF/ANE/MacOS-x86-64/${ANE_NAME}.framework > /dev/null 2>&1
        codesign_result=$?
        if [ "${codesign_result}" != "0" ]; then
            echo ${red} "Failed to sign ANE Framework: ${codesign_result}" ${white}
            exit 1
        fi
    fi
    done
fi

cd "$pathtome"
echo ${grn} "Codesign OK" ${white}

echo ${cyn} "Building .pkg" ${white}

if [ -d "$APP.pkg" ]; then
    rm -r "$APP.pkg"
fi

xcrun productbuild --component "$APP.app" /Applications --sign "$INSTALLER_KEY" "$APP.pkg" > /dev/null 2>&1
codesign_result=$?
if [ "${codesign_result}" != "0" ]; then
    echo ${red} "Failed to build pkg: ${codesign_result}" ${white}
    exit 1
fi

echo ${cyn}"Validate app..." ${white}

xcrun altool -t osx -f "$APP.pkg" --primary-bundle-id "$BUNDLE_ID" --validate-app -u "$TWO_FAC_UN" -p "$TWO_FAC_PW" > /dev/null 2>&1
validate_result=$?
if [ "${validate_result}" != "0" ]; then
    echo ${red}"Validation failed: ${validate_result}" ${white}
    exit 1
fi

cd "$pathtome"
echo ${grn} "Validation OK" ${white}
echo ${grn} "All Done!" ${white}

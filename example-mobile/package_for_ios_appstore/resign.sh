#!/bin/sh

IPA="/path/to/yourAppName.ipa"
PROVISIONING_PROFILE="/path/to/Distribution_Provisioning.mobileprovision"

# run this from Terminal to find your distribution identity: security find-identity -v -p codesigning
SIGNING_IDENTITY="iPhone Distribution: XXXXXXXXX (XXXXX)"


#################### DO NO MODIFY BELOW THIS LINE ####################
DESTINATION_PATH="."
SWIFT_SOURCE_PATH="/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/swift/iphoneos"
cp $PROVISIONING_PROFILE .
cp $IPA .

PROVISIONING_PROFILE="${PROVISIONING_PROFILE##*/}"
IPA="${IPA##*/}"


#Args processing
if [ "$IPA" == "" ];
then
echo "Usage: sh resign.sh ipa_path provisioning_path destination_path signing_identity"
exit 1
fi

if [ ! -f "$IPA" ];
then
echo "Cannot find IPA, given path: ${IPA}"
exit 1
fi

if [ ! -f "$PROVISIONING_PROFILE" ];
then
echo "Cannot find Provisioning profile, given path: ${PROVISIONING_PROFILE}"
exit 1
fi

if [ "$DESTINATION_PATH" == "" ];
then
echo "Usage: sh resign.sh ipa_path provisioning_path destination_path signing_identity"
exit 1
fi

if [ ! -d "$DESTINATION_PATH" ];
then
mkdir -p $DESTINATION_PATH
fi

codes_availables=$(security find-identity -p codesigning -v | grep -o '".*"' | tr -d '"')

if [ "$SIGNING_IDENTITY" == "" ] || [[ $codes_availables != *$SIGNING_IDENTITY* ]];
then
echo "The signing identity not exists."
exit 1
fi

IPA_CONTENT_PATH="ipa_content"

#Unzip ipa
if [ -d $IPA_CONTENT_PATH ]
then
rm -rf $IPA_CONTENT_PATH
fi
unzip ${IPA} -d $IPA_CONTENT_PATH

## make folder for Swift Store
if [ -d "$IPA_CONTENT_PATH/SwiftSupport" ]; then
rm -r "$IPA_CONTENT_PATH/SwiftSupport"
fi
mkdir "$IPA_CONTENT_PATH/SwiftSupport"
mkdir "$IPA_CONTENT_PATH/SwiftSupport/iphoneos"
find . -iname '$IPA_CONTENT_PATH/*.DS_Store' -exec rm {} \;


#Data analysis
echo "Analysing data..."
PROVISIONING_PROFILE_DECRYPTED="${DESTINATION_PATH}/${PROVISIONING_PROFILE}.plist"

echo $PROVISIONING_PROFILE_DECRYPTED
security cms -D -i "${PROVISIONING_PROFILE}" > "${PROVISIONING_PROFILE_DECRYPTED}"

APP_NAME=$(ls -1 $IPA_CONTENT_PATH/Payload)
echo "APP Name: ${APP_NAME}"

TEAM_IDENTIFIER=$(/usr/libexec/Plistbuddy -c "Print :TeamIdentifier:0" "${PROVISIONING_PROFILE_DECRYPTED}")
echo "Team Identifier: ${TEAM_IDENTIFIER}"

APPLICATION_IDENTIFIER_PREFIX=$(/usr/libexec/Plistbuddy -c "Print :ApplicationIdentifierPrefix:0" "${PROVISIONING_PROFILE_DECRYPTED}")
echo "Application Identifier Prefix: ${APPLICATION_IDENTIFIER_PREFIX}"

echo "Signing Identity: ${SIGNING_IDENTITY}"

BUNDLE_IDENTIFIER=$(/usr/libexec/Plistbuddy -c "Print :CFBundleIdentifier" $IPA_CONTENT_PATH/Payload/${APP_NAME}/Info.plist)
echo "Bundle Identifier: ${BUNDLE_IDENTIFIER}"

PROVISIONING_DEVICES=$(/usr/libexec/Plistbuddy -c "Print :ProvisionedDevices" "${PROVISIONING_PROFILE_DECRYPTED}")
if [ "$PROVISIONING_DEVICES" == "" ];
then
echo "Provisioning profile WITHOUT attached devices"
HAS_DEVICES="NO"
else
echo "Provisioning profile WITH attached devices"
HAS_DEVICES="YES"
fi
PROVISIONING_GET_TASK_ALLOW=$(/usr/libexec/Plistbuddy -c "Print :Entitlements:get-task-allow" "${PROVISIONING_PROFILE_DECRYPTED}")
echo "Provisioning get-task-allow: ${PROVISIONING_GET_TASK_ALLOW}"

/bin/rm "${PROVISIONING_PROFILE_DECRYPTED}"


#Cleaning Ipacontent files
rm -rf $IPA_CONTENT_PATH/Payload/${APP_NAME}/_CodeSignature/
rm -f $IPA_CONTENT_PATH/Payload/${APP_NAME}/embedded.mobileprovision


#Setting a new identity
cp ${PROVISIONING_PROFILE} $IPA_CONTENT_PATH/Payload/${APP_NAME}/embedded.mobileprovision
APP_ENTITLEMENTS="$DESTINATION_PATH/Entitlements.plist"
if [ -f ${APP_ENTITLEMENTS} ]
then
rm -f ${APP_ENTITLEMENTS}
fi

/usr/libexec/PlistBuddy -c "Add :application-identifier string ${APPLICATION_IDENTIFIER_PREFIX}.${BUNDLE_IDENTIFIER}" "${APP_ENTITLEMENTS}"

if [ ${HAS_DEVICES} == "NO" ] && [ ${PROVISIONING_GET_TASK_ALLOW} == "false" ]
then
/usr/libexec/PlistBuddy -c "Add :beta-reports-active bool true" "${APP_ENTITLEMENTS}"
fi

/usr/libexec/PlistBuddy -c "Add :get-task-allow bool ${PROVISIONING_GET_TASK_ALLOW}" "${APP_ENTITLEMENTS}"
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups array" "${APP_ENTITLEMENTS}"
/usr/libexec/PlistBuddy -c "Add :keychain-access-groups:0 string ${APPLICATION_IDENTIFIER_PREFIX}.${BUNDLE_IDENTIFIER}" "${APP_ENTITLEMENTS}"
cp "${APP_ENTITLEMENTS}" "$IPA_CONTENT_PATH/Payload/${APP_NAME}/archived-expanded-entitlements.xcent"


#Resigning
echo "Resigning the app with identity: ${SIGNING_IDENTITY}"
if [ -d "$IPA_CONTENT_PATH/Payload/${APP_NAME}/Frameworks" ];
then
for SWIFT_LIB in $(ls -1 $IPA_CONTENT_PATH/Payload/${APP_NAME}/Frameworks); do
SWIFT_SOURCE="$SWIFT_SOURCE_PATH/$SWIFT_LIB"
if [ -f "$SWIFT_SOURCE" ]; then
cp "$SWIFT_SOURCE" "$IPA_CONTENT_PATH/SwiftSupport/iphoneos"
cp "$SWIFT_SOURCE" "$IPA_CONTENT_PATH/Payload/${APP_NAME}/Frameworks"
else
codesign --force --sign "${SIGNING_IDENTITY}" --verbose "$IPA_CONTENT_PATH/Payload/${APP_NAME}/Frameworks/${SWIFT_LIB}"
fi
done
fi
codesign --force --entitlements "${APP_ENTITLEMENTS}" --sign "${SIGNING_IDENTITY}" "$IPA_CONTENT_PATH/Payload/${APP_NAME}" --verbose
codesign --verify --verbose --deep --no-strict "$IPA_CONTENT_PATH/Payload/${APP_NAME}"


#Packaging
IPA_APPSTORE_PATH="${DESTINATION_PATH}/${IPA%.*}_APPSTORE.ipa"
cd $IPA_CONTENT_PATH
zip --symlinks --verbose --recurse-paths "../APPSTORE.ipa" .
cd ..
mv "APPSTORE.ipa" "${IPA_APPSTORE_PATH}"

#Cleaning tmp files
rm -rf $IPA_CONTENT_PATH
rm $APP_ENTITLEMENTS

rm $PROVISIONING_PROFILE

#Output
echo
echo "***************************"
echo

if [ ${HAS_DEVICES} == "NO" ] && [ ${PROVISIONING_GET_TASK_ALLOW} == "false" ]
then
echo "IPA succesfully signed for AppStore Distribution. This binary is NOT COMPATIBLE for AdHoc Deployment or Development."
elif [ ${HAS_DEVICES} == "YES" ] && [ ${PROVISIONING_GET_TASK_ALLOW} == "false" ]
then
echo "IPA succesfully signed for AdHoc Distribution. This binary is not compatible for AppStore Deployment."
else
echo "IPA succesfully signed for Development Distribution. This binary is NOT COMPATIBLE for AppStore Deployment or Adhoc Distribution."
fi

echo
echo "Result IPA: ${IPA_APPSTORE_PATH}"
echo
echo "***************************"
echo

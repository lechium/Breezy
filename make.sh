#!/bin/bash

rm -rf layout/Applications/AirDropHelper.app/
LAYOUT="layout"
CONTROL_FILE=control
DPKG_DEBIAN_PATH="$LAYOUT"/DEBIAN
APPS="$LAYOUT"/Applications
mkdir -p $APPS

pushd AirDropHelper
rm -rf build
/usr/bin/xcodebuild BUILD_ROOT=../build | xcpretty
ldid2 -Sent.plist build/Release-appletvos/AirDropHelper.app/AirDropHelper
rm -rf build/Release-appletvos/AirDropHelper.app/embedded.mobileprovision
rm -rf build/Release-appletvos/AirDropHelper.app/_CodeSignature
cp -r build/Release-appletvos/AirDropHelper.app ../layout/Applications/
popd

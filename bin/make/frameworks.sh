#!/usr/bin/env bash

rm -rf build

set -e

if [[ "${SHELL}" =~ "zsh" ]]; then
  echo "-o pipefail is not available in zsh.  You have been warned."
else
  set -o pipefail
fi

if [ "${XCPRETTY}" = "0" ]; then
  USE_XCPRETTY=
else
  USE_XCPRETTY=`which xcpretty | tr -d '\n'`
fi

if [ ! -z ${USE_XCPRETTY} ]; then
  XC_PIPE='xcpretty -c'
else
  XC_PIPE='cat'
fi

BUILD_DIR="build"
PRODUCTS_DIR="Products/Framworks"
CONFIGURATION=Release

mkdir -p "${PRODUCTS_DIR}"

XC_PROJECT="FBSimulatorControl.xcodeproj"

function strip_framework() {
  local FRAMEWORK_PATH="${BUILD_DIR}/Build/Products/${CONFIGURATION}/${1}"
  if [ -d "$FRAMEWORK_PATH" ]; then
    rm -r "$FRAMEWORK_PATH"
  fi
}

function framework_build() {
  local target="${1}"
  xcrun xcodebuild \
    DEBUG_INFORMATION_FORMAT=dwarf-with-dsym \
    ENABLE_TESTABILITY=NO \
    GCC_OPTIMIZATION_LEVEL=s \
    -SYMROOT="${BUILD_DIR}" \
    -OBJROOT="${BUILD_DIR}" \
    -project "${XC_PROJECT}" \
    -target "${target}" \
    -configuration "${CONFIGURATION}" \
    -sdk macosx \
    build | $XC_PIPE
}

framework_build XCTestBootstrap
framework_build FBSimulatorControl
framework_build FBDeviceControl
framework_build FBControlCore

# See the Frameworks.xcconfig file for why this is necessary.
strip_framework "FBSimulatorControlKit.framework/Versions/Current/Frameworks/FBSimulatorControl.framework"
strip_framework "FBSimulatorControlKit.framework/Versions/Current/Frameworks/FBDeviceControl.framework"
strip_framework "FBSimulatorControl.framework/Versions/Current/Frameworks/XCTestBootstrap.framework"
strip_framework "FBSimulatorControl.framework/Versions/Current/Frameworks/FBControlCore.framework"
strip_framework "FBSimulatorControl.framework/Versions/Current/Frameworks/CocoaLumberjack.framework"
strip_framework "FBDeviceControl.framework/Versions/Current/Frameworks/XCTestBootstrap.framework"
strip_framework "FBDeviceControl.framework/Versions/Current/Frameworks/FBControlCore.framework"
strip_framework "FBDeviceControl.framework/Versions/Current/Frameworks/CocoaLumberjack.framework"
strip_framework "XCTestBootstrap.framework/Versions/Current/Frameworks/FBControlCore.framework"
strip_framework "XCTestBootstrap.framework/Versions/Current/Frameworks/CocoaLumberjack.framework"
strip_framework "FBControlCore.framework/Versions/Current/Frameworks/CocoaLumberjack.framework"



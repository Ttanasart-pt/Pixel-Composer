#!/bin/bash
# This script will run the original build script in a Steam Linux Runtime environment
# You are free to change these:
BUILD_DIR="$PWD/../../../../"
STEAMRT_SDK_DIR="/opt/steam-runtime"
# Do the magic
echo Build dir: "$BUILD_DIR"
echo SteamRT SDK dir: "$STEAMRT_SDK_DIR"
echo Starting build...
cd "$BUILD_DIR"
unshare -mUprf sh -c 'mount -o bind "$1" "$2/tmp" && chroot "$2" sh -c "cd /tmp && chmod a+x -R . && export YYSTEAMRT=1 && Steamworks_gml/extensions/steamworks/steamworks_linux/build_linux64.sh"' -- "$BUILD_DIR" "$STEAMRT_SDK_DIR"

echo Exit code is $?


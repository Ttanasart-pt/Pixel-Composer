#!/bin/bash

echo "=========================================="
echo "Running remote re-signing on macOS..."
echo "=========================================="

# GameMaker sets YYlocation to the output folder on the Mac
APP_PATH="$YYlocation/$YYproject_name.app"
INFO_PLIST="$APP_PATH/Contents/Info.plist"
ENTITLEMENTS_PATH="$YYproject_dir/entitlements.plist"
SIGN_IDENTITY="Developer ID Application: Tanasart Phuangtong (N2CW2XZMYC)"

# Check for entitlements file
if [ ! -f "$ENTITLEMENTS_PATH" ]; then
    echo "ERROR: Could not find entitlements.plist at $ENTITLEMENTS_PATH"
    exit 1
fi

if [ ! -f "$INFO_PLIST" ]; then
    echo "ERROR: Could not find Info.plist at $INFO_PLIST"
    exit 1
fi

echo "Injecting .pxc file association into Info.plist..."
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes array" "$INFO_PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0 dict" "$INFO_PLIST" 2>/dev/null
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeName string 'Pixel Composer Project'" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeRole string 'Editor'" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:LSHandlerRank string 'Owner'" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions array" "$INFO_PLIST"
/usr/libexec/PlistBuddy -c "Add :CFBundleDocumentTypes:0:CFBundleTypeExtensions:0 string 'pxc'" "$INFO_PLIST"

echo "Re-signing app bundle..."
codesign --force --options runtime --deep --timestamp --entitlements "$ENTITLEMENTS_PATH" --sign "$SIGN_IDENTITY" "$APP_PATH"

echo "Build step completed successfully!"
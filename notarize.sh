#!/bin/bash

# This script is used to notarize the macOS app.
# It is an alternative to Godot's built-in notarization.
# It assumes that you have Xcode installed and configured with your Apple Developer account.

# IMPORTANT: Replace the placeholder values below with your own Apple Developer account information.
# You can find your Team ID in the "Membership" section of your Apple Developer account.
# You can create an app-specific password at https://appleid.apple.com.
TEAM_ID="YOUR_TEAM_ID"
APPLE_ID="YOUR_APPLE_ID"
APP_SPECIFIC_PASSWORD="@keychain:AC_PASSWORD" # Or replace with your app-specific password

# The path to the exported .dmg file
DMG_PATH="build/macos/AvatarStream.dmg"

# The primary bundle ID of your app
BUNDLE_ID="com.example.avatarstream"

# Check if the dmg path exists
if [ ! -f "$DMG_PATH" ]; then
    echo "Error: DMG file not found at $DMG_PATH"
    exit 1
fi

# Upload the app to Apple for notarization
echo "Uploading app for notarization..."
xcrun altool --notarize-app --primary-bundle-id "$BUNDLE_ID" --username "$APPLE_ID" --password "$APP_SPECIFIC_PASSWORD" --team-id "$TEAM_ID" --file "$DMG_PATH"

echo "Notarization request submitted successfully."
echo "You will receive an email when the process is complete."

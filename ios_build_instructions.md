# iOS Build Instructions

This document provides instructions for building the iOS version of the Medicine Reminder app.

## Prerequisites

- A Mac computer with macOS
- Xcode installed (latest version recommended)
- An Apple Developer account
- Flutter SDK installed

## Setup

1. Clone the repository or copy the project files to your Mac
2. Open Terminal and navigate to the project directory
3. Run `flutter pub get` to install dependencies

## Configure iOS-specific settings

1. Make sure the sound file is in the correct location:
   ```
   cp android/app/src/main/res/raw/loud_alarm.mp3 ios/Runner/Resources/
   ```

2. Open the iOS project in Xcode:
   ```
   open ios/Runner.xcworkspace
   ```

3. In Xcode, select the Runner project in the Project Navigator
4. Select the Runner target
5. Go to the "Signing & Capabilities" tab
6. Select your Team (Apple Developer account)
7. Update the Bundle Identifier if needed (must be unique)

## Build the app

### Option 1: Build using Flutter

1. Run the following command to build the iOS app:
   ```
   flutter build ipa
   ```

2. The IPA file will be generated at:
   ```
   build/ios/ipa/app_md.ipa
   ```

### Option 2: Build using Xcode

1. Open the iOS project in Xcode:
   ```
   open ios/Runner.xcworkspace
   ```

2. Select Product > Archive from the menu
3. Once the archive is complete, click "Distribute App"
4. Follow the prompts to create an IPA file

## Submit to App Store

1. Open App Store Connect (https://appstoreconnect.apple.com/)
2. Create a new app or select your existing app
3. Upload the IPA file using Xcode or Transporter
4. Complete the app information, screenshots, and metadata
5. Submit for review

## Testing on a device

1. Connect your iOS device to your Mac
2. In Xcode, select your device from the device dropdown
3. Click the Run button to build and install the app on your device

## Troubleshooting

- If you encounter build errors, make sure your Xcode and Flutter versions are up to date
- Check that all required permissions are properly configured in Info.plist
- Ensure the sound file is correctly added to the Xcode project
- Verify that your Apple Developer account has a valid membership 
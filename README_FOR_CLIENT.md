# Medicine Reminder App

## Overview

This is a medicine reminder application that helps users track their medication schedule. The app provides notifications at scheduled times to remind users to take their medicine.

## Features

- Add, edit, and delete medicine reminders
- Schedule notifications for medicine reminders
- View upcoming medicine reminders
- Sound alerts for notifications
- Arabic language support
- Right-to-left (RTL) layout

## Building the App

### Android

To build the Android version of the app:

1. Make sure you have Flutter SDK installed
2. Open a terminal and navigate to the project directory
3. Run `flutter build apk --release` to build an APK file
4. The APK file will be generated at `build/app/outputs/flutter-apk/app-release.apk`

### iOS

Building the iOS version requires a Mac computer with Xcode installed. Please refer to the `ios_build_instructions.md` file for detailed instructions.

## Installation

### Android

1. Transfer the APK file to your Android device
2. Open the file on your device to install the app
3. You may need to enable "Install from Unknown Sources" in your device settings

### iOS

The iOS version must be distributed through the App Store or TestFlight. Please contact your developer for assistance with iOS deployment.

## Usage

1. Open the app
2. Click the "+" button to add a new medicine reminder
3. Fill in the medicine details (name, dose, time, etc.)
4. Save the reminder
5. The app will notify you at the scheduled time

## Troubleshooting

### Notifications not working

- Make sure notifications are enabled in your device settings
- Check that the app has permission to send notifications
- Ensure your device is not in Do Not Disturb mode

### Sound not playing

- Check that your device volume is turned up
- Make sure the app has permission to play sounds
- Verify that the sound file is properly included in the app

## Contact

If you encounter any issues or have questions, please contact your developer for assistance. 
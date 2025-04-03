# Medicines App

A Flutter application that helps you save medicines and sends reminders when you need to take them.

## Features

- Save medicines in local database
- Show notifications at the correct time
- Delete medicines
- Track your medicine schedule with a calendar view

## Getting Started

1. Clone this repository
2. Run `flutter pub get` to install dependencies
3. Add the required image assets to the `assets/images` folder:
   - `welcome_image.png` - Welcome screen image
   - `pill.png` - Pill icon
   - `syrup.png` - Syrup icon
   - `tablet.png` - Tablet icon
   - `capsule.png` - Capsule icon
4. Run the app with `flutter run`

## Dependencies

- flutter_cupertino_icons
- intl
- sqflite
- auto_size_text
- path
- flutter_local_notifications
- timezone
- animated_text_kit
- animated_widgets

## Project Structure

```
lib/
  ├── database/
  │   ├── pills_database.dart
  │   └── repository.dart
  ├── helpers/
  │   ├── platform_flat_button.dart
  │   ├── platform_slider.dart
  │   └── snack_bar.dart
  ├── models/
  │   ├── calendar_day_model.dart
  │   ├── medicine_type.dart
  │   └── pill.dart
  ├── notifications/
  │   └── notifications.dart
  ├── screens/
  │   ├── add_new_medicine/
  │   │   ├── add_new_medicine.dart
  │   │   ├── form_fields.dart
  │   │   ├── medicine_type_card.dart
  │   │   └── slider.dart
  │   ├── home/
  │   │   ├── calendar.dart
  │   │   ├── calendar_day.dart
  │   │   ├── home.dart
  │   │   ├── medicine_card.dart
  │   │   └── medicines_list.dart
  │   └── welcome/
  │       ├── title_and_message.dart
  │       └── welcome.dart
  └── main.dart
```

## Screenshots

- Welcome Screen
- Add Pills Screen
- Home Screen
- Notification Screen

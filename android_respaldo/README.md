# Getting Started with Flutter on Android

This directory contains the Android build configuration for your Flutter application.

## Running the App

To run your app on an Android device or emulator:

```bash
flutter run
```

## Building APK

To build a release APK:

```bash
flutter build apk --release
```

To build a release app bundle (.aab):

```bash
flutter build appbundle --release
```

## Configuration

The Android build configuration can be modified by:

1. Editing `android/build.gradle` for project-wide settings
2. Editing `android/app/build.gradle` for app-specific settings
3. Modifying AndroidManifest.xml for app permissions and activities

## Permissions

Make sure the following permissions are configured in `AndroidManifest.xml`:

- INTERNET
- ACCESS_NETWORK_STATE

For more information, see the [Flutter documentation](https://flutter.dev/docs/deployment/android).

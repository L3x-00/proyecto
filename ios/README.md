# Getting Started with Flutter on iOS

This directory contains the iOS build configuration for your Flutter application.

## Running the App

To run your app on an iOS device or simulator:

```bash
flutter run
```

## Building for iOS

To build an iOS app:

```bash
flutter build ios --release
```

To build an iOS app archive for App Store submission:

```bash
flutter build ios --release
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -config Release-iphoneos archive -archivePath build/Runner.xcarchive
```

## Configuration

The iOS build configuration can be modified by opening `ios/Runner.xcworkspace` in Xcode.

## Permissions

Make sure the following permissions are configured in `ios/Runner/Info.plist`:

- NSLocalNetworkUsageDescription
- NSNetServiceUsageDescription
- NSBonjourServiceTypes

For more information, see the [Flutter documentation](https://flutter.dev/docs/deployment/ios).

# kaya-flutter

iOS and Android apps for Kaya, the local-first bookmarking engine.

## Development Environment Setup

### Prerequisites

1. **mise** - Install [mise](https://mise.jdx.dev/) for managing Flutter and Ruby versions
2. **Xcode** (macOS only) - Required for iOS builds. Install from the Mac App Store.
3. **Android Studio** - Required for Android builds. Install from https://developer.android.com/studio

### Ruby and CocoaPods Setup (macOS only)

CocoaPods is required for iOS dependencies. Install it via mise-managed Ruby:

```bash
# Install Ruby via mise (version specified in mise.toml)
mise install ruby

# Install CocoaPods
gem install cocoapods
```

### Flutter Setup

```bash
# Install Flutter via mise
mise install

# Verify Flutter installation
flutter doctor

# Get dependencies
flutter pub get

# Generate code (Riverpod, Freezed)
flutter pub run build_runner build --delete-conflicting-outputs
```

### IDE Setup (Optional)

For VS Code, install the Flutter and Dart extensions.

For Android Studio, install the Flutter and Dart plugins.

## Local Build

### Android

#### Run on Connected Device

```bash
# List connected devices
flutter devices

# Run on a specific device (replace DEVICE_ID with your device ID)
flutter run -d DEVICE_ID

# Run on any available Android device
flutter run -d android
```

#### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# The APK will be at: build/app/outputs/flutter-apk/app-debug.apk (or app-release.apk)
```

#### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS

#### Run on Connected Device

```bash
# List connected devices
flutter devices

# Run on a specific iOS device (replace DEVICE_ID with your device ID)
flutter run -d DEVICE_ID

# Run on any available iOS device
flutter run -d ios
```

#### Run on Simulator

```bash
# Open iOS Simulator
open -a Simulator

# Run on simulator
flutter run -d simulator
```

#### Build for Device

```bash
# Debug build
flutter build ios --debug

# Release build (requires signing configuration)
flutter build ios --release
```

Note: For iOS device builds, you need to:
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select your Development Team in Signing & Capabilities
3. Ensure the device is trusted and paired

## Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run a specific test file
flutter test test/features/anga/models/anga_test.dart
```

## Code Quality

```bash
# Analyze code for issues
flutter analyze

# Format code
dart format lib test
```

## Troubleshooting

### Gradle Lock Issues (Android)

If you see "Timeout waiting to lock" errors:

```bash
# Kill Gradle daemons
pkill -9 -f GradleDaemon

# Remove lock files
find ~/.gradle -name "*.lock" -delete

# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

### CocoaPods Issues (iOS)

If you see CocoaPods-related errors:

```bash
cd ios
pod deintegrate
pod install --repo-update
cd ..
flutter clean
flutter pub get
```

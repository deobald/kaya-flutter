# kaya-flutter

iOS and Android apps for Kaya, the local-first bookmarking engine.

## Minimum Android and iOS Versions

* Android: `grep "val minSdkVersion" "$(flutter sdk-path)/packages/flutter_tools/gradle/src/main/kotlin/FlutterExtension.kt"` => 24
* iOS: `grep '^platform' ios/Podfile` => 14

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

## Screenshots

FYI: `bin/take-screenshots.sh` seems to be broken, but I don't have the time to debug it right now. -sd

Store listing screenshots can be generated from emulators using `bin/take-screenshots.sh`. Output goes to `tmp/screenshots/`.

```bash
# Take all screenshots (Android + iOS)
./bin/take-screenshots.sh

# Android only
./bin/take-screenshots.sh android

# iOS only
./bin/take-screenshots.sh ios
```

### Android (Google Play)

Google Play requires screenshots for phone, 7-inch tablet, and 10-inch tablet. The script creates AVDs for each:

| Form Factor | AVD Device   | Resolution  |
|-------------|-------------|-------------|
| Phone       | Pixel 4      | 1080x2280   |
| 7" Tablet   | Nexus 7 2013 | 1200x1920   |
| 10" Tablet  | Nexus 10     | 2560x1600   |

Requires an x86_64 system image. The script installs `system-images;android-30;google_apis;x86_64` if missing.

To take screenshots manually:

```bash
# Create and boot an AVD
$ANDROID_SDK/cmdline-tools/latest/bin/avdmanager create avd --name my_avd --package "system-images;android-30;google_apis;x86_64" --device "pixel_4"
$ANDROID_SDK/emulator/emulator -avd my_avd &

# Build, install, and launch
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk
adb shell am start -n org.savebutton.app/.MainActivity

# Capture
adb exec-out screencap -p > screenshot.png

# Shut down
adb emu kill
```

### iOS (App Store)

App Store requires screenshots for 6.9" iPhone (1290x2796) and 13" iPad (2064x2752). Apple auto-scales for other device sizes.

| Form Factor | Simulator             | Resolution  |
|-------------|-----------------------|-------------|
| 6.9" iPhone | iPhone 16 Pro Max     | 1260x2736   |
| 13" iPad    | iPad Pro 13-inch (M4) | 2064x2752   |

To take screenshots manually:

```bash
# List available simulators
xcrun simctl list devices available

# Boot a simulator
xcrun simctl boot "iPhone 16 Pro Max"

# Build, install, and launch
flutter build ios --debug --simulator
xcrun simctl install booted build/ios/iphonesimulator/Runner.app
xcrun simctl launch booted org.savebutton.app

# Capture
xcrun simctl io booted screenshot screenshot.png

# Shut down
xcrun simctl shutdown booted
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

## Codemagic

iOS and Android apps are released via Codemagic. Use [codemagic-cli-tools](https://docs.codemagic.io/knowledge-codemagic/codemagic-cli-tools/) whenever possible:

* [`codemagic-cli-tools`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/codemagic-cli-tools/README.md)
* [`git-changelog`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/git-changelog/README.md)

**iOS:**
* [`app-store-connect`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/app-store-connect/README.md)
* [`xcode-project`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/xcode-project/README.md)
* [`keychain`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/keychain/README.md)

**Android:**
* [`android-app-bundle`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/android-app-bundle/README.md)
* [`android-keystore`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/android-keystore/README.md)
* [`google-play`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/google-play/README.md)
* [`universal-apk`](https://github.com/codemagic-ci-cd/cli-tools/blob/master/docs/universal-apk/README.md)

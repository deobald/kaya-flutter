#!/usr/bin/env bash
set -euo pipefail

# take-screenshots.sh — Take app screenshots for Google Play and App Store
#
# Usage:
#   ./bin/take-screenshots.sh [android|ios|all]
#
# Prerequisites:
#   Android: Android SDK with emulator, system image, and platform-tools
#   iOS:     Xcode with iOS Simulator runtimes installed
#
# Output: tmp/screenshots/

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT_DIR="$PROJECT_DIR/tmp/screenshots"
mkdir -p "$OUT_DIR"

ANDROID_SDK="${ANDROID_HOME:-$HOME/Library/Android/sdk}"
ADB="$ANDROID_SDK/platform-tools/adb"
EMU="$ANDROID_SDK/emulator/emulator"
AVDMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/avdmanager"
SDKMANAGER="$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager"

APK="$PROJECT_DIR/build/app/outputs/flutter-apk/app-debug.apk"
PACKAGE="org.savebutton.app"
ACTIVITY="$PACKAGE/.MainActivity"

# --- Android configuration ---
# Google Play requires:
#   Phone:      16:9 or 9:16, min 320px, max 3840px per side
#   7-inch tab: 16:9 or 9:16, min 320px, max 3840px per side
#   10-inch tab: 16:9 or 9:16, min 320px, max 3840px per side
# Recommended: 1080x1920 (phone), 1200x1920 (7"), 1600x2560 (10")

ANDROID_SYSTEM_IMAGE="system-images;android-30;google_apis;x86_64"
ANDROID_AVDS=(
  "screenshot_phone:pixel_4"
  "screenshot_7inch:Nexus 7 2013"
  "screenshot_10inch:Nexus 10"
)

# --- iOS configuration ---
# App Store requires (mandatory minimums):
#   6.9" iPhone: 1260x2736 (iPhone 16 Pro Max)
#   13" iPad:    2064x2752 (iPad Pro M4)
# These two cover all required size classes. Apple auto-scales for other devices.

IOS_SIMULATORS=(
  "iPhone 16 Pro Max"
  "iPad Pro 13-inch (M4)"
)

wait_for_android_boot() {
  local max_attempts="${1:-90}"
  echo "  Waiting for emulator to boot (up to $((max_attempts * 3))s)..."
  for i in $(seq 1 "$max_attempts"); do
    local boot
    boot=$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r') || true
    if [ "$boot" = "1" ]; then
      echo "  Booted after ~$((i * 3))s"
      return 0
    fi
    sleep 3
  done
  echo "  ERROR: Emulator did not boot in time"
  return 1
}

take_android_screenshots() {
  echo "=== Android Screenshots ==="

  # Ensure system image is installed
  if ! "$SDKMANAGER" --list_installed 2>/dev/null | grep -q "$(echo $ANDROID_SYSTEM_IMAGE | sed 's/;/|/g' | sed 's/|/;/g')"; then
    echo "Installing system image: $ANDROID_SYSTEM_IMAGE"
    yes | "$SDKMANAGER" "$ANDROID_SYSTEM_IMAGE"
  fi

  # Build APK if missing
  if [ ! -f "$APK" ]; then
    echo "Building debug APK..."
    cd "$PROJECT_DIR"
    flutter build apk --debug
  fi

  for avd_spec in "${ANDROID_AVDS[@]}"; do
    local avd_name="${avd_spec%%:*}"
    local device="${avd_spec#*:}"
    local label="${avd_name#screenshot_}"

    echo ""
    echo "--- Android: $label ($device) ---"

    # Create AVD if it doesn't exist
    if ! "$AVDMANAGER" list avd 2>/dev/null | grep -q "Name: $avd_name"; then
      echo "  Creating AVD: $avd_name"
      echo "no" | "$AVDMANAGER" create avd \
        --name "$avd_name" \
        --package "$ANDROID_SYSTEM_IMAGE" \
        --device "$device" \
        --force
    fi

    # Boot emulator
    echo "  Starting emulator..."
    "$EMU" -avd "$avd_name" -no-audio -no-boot-anim -no-window -gpu swiftshader_indirect -port 5554 &
    local emu_pid=$!

    "$ADB" wait-for-device
    if ! wait_for_android_boot 90; then
      kill "$emu_pid" 2>/dev/null || true
      echo "  Skipping $label"
      continue
    fi

    # Install and launch
    echo "  Installing app..."
    "$ADB" install -r "$APK"
    "$ADB" shell am start -n "$ACTIVITY"
    echo "  Waiting for app to render..."
    sleep 10

    # Capture
    local outfile="$OUT_DIR/android_${label}.png"
    "$ADB" exec-out screencap -p > "$outfile"
    echo "  Saved: $outfile"

    # Shut down
    "$ADB" emu kill 2>/dev/null || true
    wait "$emu_pid" 2>/dev/null || true
    sleep 3
  done

  echo ""
  echo "=== Android screenshots complete ==="
}

take_ios_screenshots() {
  echo "=== iOS Screenshots ==="

  # Build for simulator if needed
  echo "Building for iOS Simulator..."
  cd "$PROJECT_DIR"
  flutter build ios --debug --simulator

  for sim_name in "${IOS_SIMULATORS[@]}"; do
    local label
    label=$(echo "$sim_name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | sed 's/[()]//g')

    echo ""
    echo "--- iOS: $sim_name ---"

    # Find or create simulator
    local udid
    udid=$(xcrun simctl list devices available -j 2>/dev/null \
      | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    for d in devices:
        if d['name'] == '$sim_name' and d['isAvailable']:
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null) || true

    if [ -z "$udid" ]; then
      echo "  No simulator found for '$sim_name'. Create one in Xcode > Window > Devices and Simulators."
      continue
    fi

    # Boot simulator
    echo "  Booting simulator ($udid)..."
    xcrun simctl boot "$udid" 2>/dev/null || true
    sleep 5

    # Install and launch
    echo "  Installing app..."
    xcrun simctl install "$udid" "$PROJECT_DIR/build/ios/iphonesimulator/Runner.app"
    xcrun simctl launch "$udid" "$PACKAGE"
    echo "  Waiting for app to render..."
    sleep 8

    # Capture
    local outfile="$OUT_DIR/ios_${label}.png"
    xcrun simctl io "$udid" screenshot "$outfile"
    echo "  Saved: $outfile"

    # Shut down
    xcrun simctl shutdown "$udid" 2>/dev/null || true
    sleep 2
  done

  echo ""
  echo "=== iOS screenshots complete ==="
}

# --- Main ---

TARGET="${1:-all}"

case "$TARGET" in
  android)
    take_android_screenshots
    ;;
  ios)
    take_ios_screenshots
    ;;
  all)
    take_android_screenshots
    take_ios_screenshots
    ;;
  *)
    echo "Usage: $0 [android|ios|all]"
    exit 1
    ;;
esac

echo ""
echo "Screenshots saved to: $OUT_DIR"
ls -la "$OUT_DIR"/*.png 2>/dev/null || echo "(no screenshots found)"

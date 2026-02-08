# Codemagic App Store Troubleshooting Log

## Context

Setting up Codemagic CI/CD (`codemagic.yaml`) for the kaya-flutter project to deploy to the Apple App Store via TestFlight. The Android build is temporarily disabled (commented out in yaml) to speed up debugging the iOS build.

### Identifiers and Credentials

- Bundle ID: `org.savebutton.app` (resource ID: `7JG5QFWQR3`)
- Share Extension Bundle ID: `org.savebutton.app.ShareExtension` (resource ID: `6X73P9W7PZ`)
- App Group container: `group.org.savebutton.app`
- Team ID: `FDPGS97G76` (SaveButton / steven@savebutton.com)
- App Store Connect Issuer ID: `99e41df6-9f30-4c6c-9d39-fe4b9c7f8070`
- Key ID: `F3KU786844`
- `.p8` key file: `~/Downloads/AuthKey_F3KU786844.p8`
- Apple ID (app): `6758891680`
- App Store name: "Save Button App" ("Save Button" was taken)

### Codemagic UI Environment Variable Groups

Secrets are stored in the Codemagic web UI (not in yaml — `Encrypted()` blocks are deprecated). Two groups:

**`app_store_credentials`** (4 variables):
- `APP_STORE_CONNECT_PRIVATE_KEY` — contents of the `.p8` file
- `APP_STORE_CONNECT_KEY_IDENTIFIER` — `F3KU786844`
- `APP_STORE_CONNECT_ISSUER_ID` — `99e41df6-9f30-4c6c-9d39-fe4b9c7f8070`
- `CERTIFICATE_PRIVATE_KEY` — contents of `ios-cert-private-key.pem` (2048-bit RSA key, gitignored)

**`android_credentials`** (4 variables):
- `FCI_KEYSTORE` — base64-encoded `upload-keystore.jks`
- `FCI_KEYSTORE_PASSWORD` — keystore password
- `FCI_KEY_PASSWORD` — same as keystore password (JKS requirement)
- `FCI_KEY_ALIAS` — `org.savebutton.app`

### Current State of codemagic.yaml

- Workflow ID: `default-workflow` (Codemagic may key on this — was briefly renamed to `ios-workflow` which broke auto-triggering)
- Android steps: all commented out (key.properties, local.properties, Build AAB, android artifacts, android_credentials group)
- Google Play publishing: commented out
- iOS steps active: Get Flutter packages, Generate code, Analyze, Test, Set up iOS code signing, Build IPA
- The standalone `Install CocoaPods` step was removed (it conflicted with `flutter build ipa`'s own pod install)
- The Build IPA step currently includes a pre-build: `flutter build ios --no-codesign --release` before the actual `flutter build ipa`
- Triggering: push to master

### Related Plan Documents

- `doc/plan/2026-02-06-codemagic-app-store-setup.md` — iOS setup checklist (mostly complete)
- `doc/plan/2026-02-06-codemagic-google-play-setup.md` — Google Play setup (waiting on developer account verification)

### Remaining Work After iOS Build Succeeds

1. **TestFlight beta group:** Create "Save Button App Beta" group in App Store Connect after first successful build. Add testers: steven@savebutton.com, contact@ankursethi.com, geoff@sinfield.com, gboyer@gmail.com
2. **Re-enable Android build:** Uncomment Android steps in `codemagic.yaml`
3. **Google Play setup:** Complete steps in the Google Play plan document once the developer account is verified

---

## Build 1 — Provisioning profile doesn't support App Groups

**Log:** `tmp/2026-02-07-ipa-build-failure.txt`

**Error:**
```
Provisioning profile "Save Button ios_app_store 1770490523" doesn't support the group.org.savebutton.app App Group.
Provisioning profile "Save Button ios_app_store 1770490523" doesn't match the entitlements file's value for the com.apple.security.application-groups entitlement.
```

Same errors for the Share Extension profile.

**Root cause:** Provisioning profiles were created by `app-store-connect fetch-signing-files --create` before the App Groups capability was enabled on the bundle IDs. The profiles were created without the App Groups entitlement.

**Fix attempted:** Enabled App Groups capability on both bundle IDs via CLI:
```bash
app-store-connect bundle-ids enable-capabilities 7JG5QFWQR3 --capability "App Groups"
app-store-connect bundle-ids enable-capabilities 6X73P9W7PZ --capability "App Groups"
```

Deleted the stale INVALID profiles:
```bash
app-store-connect profiles delete Q6SYU5K39B
app-store-connect profiles delete 8QWT7XCCPD
```

Also added `fetch-signing-files` for the Share Extension bundle ID, which was missing from the original `codemagic.yaml`:
```yaml
app-store-connect fetch-signing-files "$BUNDLE_ID.ShareExtension" --type IOS_APP_STORE --create
```

---

## Build 2 — Same provisioning profile error (new profile IDs)

**Log:** `tmp/2026-02-07-2-ipa-build-failure.txt`

**Error:** Identical to Build 1 but with new profile timestamp `1770493256`.

**Root cause:** Enabling the App Groups **capability** on the bundle ID is necessary but not sufficient. The App Store Connect API can enable the capability, but it cannot **assign a specific App Group container** (e.g., `group.org.savebutton.app`) to the bundle ID. The profiles were being created with `com.apple.security.application-groups` as an empty array.

**Fix:** Manually registered the App Group container and assigned it to both bundle IDs in the Apple Developer portal:

1. Registered App Group `group.org.savebutton.app` under Identifiers > App Groups
2. Assigned it to `org.savebutton.app` via Identifiers > App IDs > App Groups > Configure
3. Assigned it to `org.savebutton.app.ShareExtension` the same way

**Note:** Xcode's auto-provisioning had previously created App Group containers under the old Pariyatti team (Z8C46829M8). These were cleaned up manually.

---

## Build 3 — Same provisioning profile error (yet again)

**Log:** `tmp/2026-02-07-3-ipa-build-failure.txt`

**Error:** Same as before — profiles don't support App Groups.

**Root cause:** The stale INVALID profiles from Build 1 had been deleted, but new profiles created by `fetch-signing-files --create` in Build 2 were also invalid (created before the App Group container was assigned). These stale Build 2 profiles needed to be deleted as well.

**Fix:** Deleted the Build 2 profiles and verified the App Group container was properly assigned. The next `fetch-signing-files --create` would create fresh profiles with the correct entitlements.

**Lesson:** When modifying bundle ID capabilities, always delete all existing provisioning profiles afterward. The `--create` flag will fetch existing profiles if they match, even if they're stale.

---

## Build 4 — receive_sharing_intent: Flutter/Flutter.h not found

**Log:** `tmp/2026-02-07-4-ipa-build-failure.txt`

**Error:**
```
Swift Compiler Error (Xcode): Clang dependency scanner failure: While building module 'receive_sharing_intent'
fatal error: 'Flutter/Flutter.h' file not found
Swift Compiler Error (Xcode): Unable to find module dependency: 'Flutter'
```

**Root cause:** The provisioning profile issue is now resolved. This is a new, different error. The `receive_sharing_intent` package (v1.8.1) has a native iOS module that imports `Flutter/Flutter.h`. The Share Extension target (`ShareViewController.swift`) imports `receive_sharing_intent` directly. During archive builds on Codemagic (likely Xcode 16 with stricter Clang dependency scanning), the Flutter framework isn't in the Share Extension's search paths.

The app builds locally but fails on CI — possibly due to Xcode version differences or a stale DerivedData cache locally.

**Fix attempted:** Removed the standalone `pod install` step from `codemagic.yaml`. The `flutter build ipa` command runs `pod install` itself and manages Flutter framework search paths. Running a separate `pod install` beforehand could produce a build state where `receive_sharing_intent`'s native code couldn't find `Flutter/Flutter.h`.

---

## Build 5 — Same receive_sharing_intent error

**Log:** `tmp/2026-02-07-5-ipa-build-failure.txt`

**Error:** Identical to Build 4.

**Root cause:** Removing the standalone `pod install` didn't help. The underlying issue is that during `flutter build ipa` (which runs `xcodebuild archive`), the Share Extension target compiles before or in parallel with the Flutter framework generation, so the `Flutter/Flutter.h` header isn't available when the Share Extension's Swift files are compiled.

**Fix attempted:** Added a pre-build step to generate the Flutter framework before the IPA build:
```yaml
- name: Build IPA (iOS)
  script: |
    # Pre-build to generate Flutter.framework for Share Extension
    flutter build ios --no-codesign --release
    # Archive and export IPA
    flutter build ipa --release \
      --build-name=1.0.$PROJECT_BUILD_NUMBER \
      --build-number=$PROJECT_BUILD_NUMBER \
      --export-options-plist=/Users/builder/export_options.plist
```

The `flutter build ios --no-codesign --release` step builds the project without code signing, which generates `Flutter.framework` and all plugin frameworks. The subsequent `flutter build ipa` should then find the headers.

---

## Build 6 — Same receive_sharing_intent error (pre-build didn't help)

**Log:** `tmp/2026-02-07-6-ipa-build-failure.txt`

**Error:** Identical to Build 4/5. Both the pre-build (`flutter build ios --no-codesign`) and the archive (`flutter build ipa`) fail with the same error.

**Root cause (confirmed):** The `receive_sharing_intent` podspec declares `s.dependency 'Flutter'`, which forces the Share Extension target to resolve Flutter framework headers. The Flutter pod in a Flutter project is a **placeholder** (`ios/Flutter/Flutter.podspec`) — it says `s.vendored_frameworks = 'path/to/nothing'`. The real `Flutter.framework` is injected by Flutter's build tooling into the **Runner** target only, not the Share Extension.

On CI (clean build, no cached DerivedData), the Share Extension target cannot find `Flutter/Flutter.h` because:
1. The Flutter pod is a placeholder with no actual framework
2. Flutter's build tooling only injects framework search paths into the Runner target
3. `inherit! :search_paths` in the Podfile inherits CocoaPods search paths but NOT the Flutter build tooling injections
4. Locally, this works because DerivedData from previous builds contains the resolved `Flutter.framework`

This is a **fundamental architectural issue** with `receive_sharing_intent` — it cannot work on CI with a Share Extension target.

**Codemagic Xcode version:** `xcode: latest` resolves to Xcode 26.2 as of Feb 2026. Xcode 15.x was deprecated and removed from Codemagic in Nov 2025, so pinning to an older version is not viable.

### Options Going Forward

1. **Migrate to `share_handler`** — This package provides a separate `share_handler_ios_models` pod with **zero Flutter dependency** for the Share Extension. The extension imports `share_handler_ios_models` instead of Flutter, so it never needs to resolve Flutter headers. This avoids the CI issue entirely.

2. **Decouple the Share Extension from Flutter manually** — Rewrite `ShareViewController.swift` to not import any Flutter-dependent package. Use a plain `SLComposeServiceViewController` that saves shared data to App Groups UserDefaults, and have the main app poll for it.

3. **Force framework search paths in Podfile** — Add explicit `FRAMEWORK_SEARCH_PATHS` for the Share Extension target in the Podfile `post_install` block. Fragile; may break across Xcode/Flutter upgrades.

### Why `receive_sharing_intent` Was Chosen Over `share_handler`

The project was originally implemented with `share_handler` (as specified in CLAUDE.md). The switch to `receive_sharing_intent` happened in commit `2ec8dbd` (Feb 2, 2025) with the message:

> `share_handler` doesn't seem to work on Android at all.
> https://github.com/anthropics/claude-code/issues/1475

The commit timeline shows 3 days of attempting to get `share_handler` working (commits `1a85aed`, `c9b6f8b`, `e3f8e2e`), including adding comprehensive Android intent filters. When Android still didn't work, the decision was made to switch to `receive_sharing_intent`.

Key notes about `share_handler`:
- It requires a native iOS Share Extension (ShareViewController.swift, storyboard, plist) — more complex setup
- Version used was `^0.0.21`; current is `^0.0.25` which may have fixed Android issues
- The CLAUDE.md still references `share_handler` as the intended package (documentation drift)

**Decision needed:** Whether to attempt migrating back to `share_handler` (which may have fixed Android issues in newer versions) or find another approach.

---

## Resolution: Migrated to `share_handler`

**Decision:** Migrated back to `share_handler` (v0.0.25). The Android bug that originally caused the switch to `receive_sharing_intent` appears to be fixed in newer versions.

**Changes made:**
- `pubspec.yaml`: `receive_sharing_intent: ^1.8.1` -> `share_handler: ^0.0.25`
- `ios/Podfile`: Added `share_handler_ios_models` pod for Share Extension target (zero Flutter dependency)
- `ios/Share Extension/ShareViewController.swift`: Imports `share_handler_ios_models`, subclasses `ShareHandlerIosViewController`
- `ios/Share Extension/Info.plist`: Updated activation rules (SUBQUERY format), added `AppGroupId` key, fixed `CFBundleVersion` (was `$(FLUTTER_BUILD_NUMBER)` which is empty for extension targets — changed to `1`)
- `ios/Runner/Info.plist`: Added `NSUserActivityTypes` with `INSendMessageIntent`
- `lib/features/share/services/share_receiver_service.dart`: Rewritten for `share_handler` API (`SharedMedia`, `SharedAttachment`)
- All deployment targets bumped from iOS 13.0 to 14.0 (`ShareHandlerIosViewController` requires 14.0+)

**Testing results (local, iOS):**
- Sharing URLs: works
- Sharing images: works
- Sharing text: initially appeared broken (white screen -> dismiss to home). Root cause was stale `ca.deobald.kaya.ShareExtension` processes from the old bundle ID interfering. After clean uninstall/reinstall with `org.savebutton.app`, text sharing works.

**Testing results (local, Android):**
- All sharing types work.

**Codemagic build 7:** IPA built successfully. Upload to App Store Connect failed due to app icon having an alpha channel.

**Codemagic build 8 (icon fix):** Stripped alpha channel from `doc/design/icon_1024.png` using ImageMagick (`convert ... -alpha remove -alpha off`), regenerated all icons via `flutter_launcher_icons`. IPA built and uploaded to App Store Connect successfully.

**Status:** iOS build and publish pipeline is fully working. Next steps:
1. Create "Save Button App Beta" TestFlight group in App Store Connect
2. Add external testers
3. Re-enable Android build in `codemagic.yaml`

---

## Key Learnings

1. **App Store Connect API limitations:** The API can enable capabilities on bundle IDs but cannot assign App Group containers. Container registration and assignment must be done manually in the Apple Developer portal.

2. **Provisioning profile lifecycle:** When bundle ID capabilities change, existing provisioning profiles become INVALID. The `fetch-signing-files --create` flag will reuse existing profiles if they exist (even stale ones), so always delete old profiles after capability changes.

3. **Xcode auto-provisioning side effects:** Xcode's automatic code signing creates App Group containers, bundle IDs, and provisioning profiles silently. When switching teams, these artifacts may be left behind on the old team and need manual cleanup.

4. **Share Extension + Flutter on CI:** The `receive_sharing_intent` package requires the Share Extension to import a Flutter-dependent native module. This works locally (where DerivedData may be warm) but can fail on CI where the Flutter framework hasn't been generated yet when the Share Extension compiles.

5. **Codemagic Encrypted() blocks deprecated:** The standalone encryption page at codemagic.io/encrypt returns 404. Secrets must be stored as environment variable groups in the Codemagic UI, referenced in yaml via `groups:`.

6. **App icon must not have alpha channel:** App Store Connect rejects uploads where the large app icon (1024x1024) has transparency or an alpha channel. Strip it with: `convert icon.png -background white -alpha remove -alpha off icon.png`

7. **Share Extension CFBundleVersion:** The `$(FLUTTER_BUILD_NUMBER)` build setting is only injected into the Runner target. The Share Extension's `Info.plist` must use a hardcoded value (e.g., `1`) for `CFBundleVersion`, or iOS will reject the install with "does not have a CFBundleVersion key with a non-zero length string value".

8. **Stale bundle IDs cause Share Extension conflicts:** When changing bundle IDs (e.g., `ca.deobald.kaya` to `org.savebutton.app`), old Share Extension processes can persist on the device. A clean uninstall/reinstall resolves phantom sharing failures.

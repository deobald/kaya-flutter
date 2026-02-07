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

**Status:** Awaiting Build 6 results.

**Fallback options if Build 6 fails:**
1. Pin `xcode: 15.4` in `codemagic.yaml` to avoid Xcode 16's stricter Clang dependency scanner
2. Upgrade `receive_sharing_intent` to a newer version (current: 1.8.1)
3. Switch to `share_handler` package (as specified in CLAUDE.md) or `flutter_sharing_intent` as an alternative
4. Restructure the Podfile to give the Share Extension target explicit access to the Flutter framework

---

## Key Learnings

1. **App Store Connect API limitations:** The API can enable capabilities on bundle IDs but cannot assign App Group containers. Container registration and assignment must be done manually in the Apple Developer portal.

2. **Provisioning profile lifecycle:** When bundle ID capabilities change, existing provisioning profiles become INVALID. The `fetch-signing-files --create` flag will reuse existing profiles if they exist (even stale ones), so always delete old profiles after capability changes.

3. **Xcode auto-provisioning side effects:** Xcode's automatic code signing creates App Group containers, bundle IDs, and provisioning profiles silently. When switching teams, these artifacts may be left behind on the old team and need manual cleanup.

4. **Share Extension + Flutter on CI:** The `receive_sharing_intent` package requires the Share Extension to import a Flutter-dependent native module. This works locally (where DerivedData may be warm) but can fail on CI where the Flutter framework hasn't been generated yet when the Share Extension compiles.

5. **Codemagic Encrypted() blocks deprecated:** The standalone encryption page at codemagic.io/encrypt returns 404. Secrets must be stored as environment variable groups in the Codemagic UI, referenced in yaml via `groups:`.

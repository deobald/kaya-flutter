# Codemagic: Apple App Store Setup

## Summary

Complete the Codemagic CI/CD configuration for building and publishing the Save Button iOS app (bundle ID `org.savebutton.app`) to the App Store via TestFlight.

## Status: COMPLETE (pending first build + TestFlight group creation)

## What Was Done

### Step 1: Apple Developer Account Verification
- Apple Developer account `steven@savebutton.com` verified
- Team ID: `FDPGS97G76`

### Step 2: App Store Connect API Key (MANUAL - Steven)
- API key created in App Store Connect:
  - Issuer ID: `99e41df6-9f30-4c6c-9d39-fe4b9c7f8070`
  - Key ID: `F3KU786844`
  - `.p8` file: `~/Downloads/AuthKey_F3KU786844.p8`

### Step 3: iOS Certificate Private Key (AUTOMATED)
- Generated `ios-cert-private-key.pem` in the project root (gitignored)

### Step 4: Bundle IDs and Signing Files (AUTOMATED)
- Registered `org.savebutton.app` (resource ID: `7JG5QFWQR3`) under team `FDPGS97G76`
- Registered `org.savebutton.app.ShareExtension` (resource ID: `6X73P9W7PZ`)
- Enabled App Groups capability on both bundle IDs
- Created distribution certificate `YA2B86TDYT`
- Created App Store provisioning profiles for both bundle IDs

### Step 5: App Created in App Store Connect (MANUAL - Steven)
- App name: "Save Button App" ("Save Button" was taken)
- Apple ID: `6758891680`
- SKU: `org.savebutton.app`

### Step 6: Secrets Configured
- Codemagic no longer supports inline `Encrypted(...)` blocks for new apps
- Secrets stored as environment variable groups in the Codemagic UI:
  - Group `app_store_credentials`: `APP_STORE_CONNECT_ISSUER_ID`, `APP_STORE_CONNECT_KEY_IDENTIFIER`, `APP_STORE_CONNECT_PRIVATE_KEY`, `CERTIFICATE_PRIVATE_KEY`
  - Group `android_credentials`: `FCI_KEYSTORE`, `FCI_KEYSTORE_PASSWORD`, `FCI_KEY_PASSWORD`, `FCI_KEY_ALIAS`
- `codemagic.yaml` references these groups instead of inline encrypted values

### Step 7: TestFlight Beta Group
- `codemagic.yaml` configured with beta group name `Save Button App Beta`
- **TODO after first build**: Create the "Save Button App Beta" external testing group in App Store Connect and add these testers:
  - steven@savebutton.com
  - contact@ankursethi.com
  - geoff@sinfield.com
  - gboyer@gmail.com

### Step 8: .gitignore Updated
- Added `ios-cert-private-key.pem` and `*.p8`

### Bundle ID and Team ID Migration
- Bundle ID changed from `com.savebutton.app` to `org.savebutton.app` across all files
- Development Team changed from `Z8C46829M8` (Pariyatti) to `FDPGS97G76` (SaveButton) across all files
- Old bundle IDs removed from Pariyatti team

## Files Modified

- `codemagic.yaml` — environment variable groups, App Store Connect publishing config
- `.gitignore` — added `ios-cert-private-key.pem`, `*.p8`
- `ios/Runner.xcodeproj/project.pbxproj` — bundle IDs and team ID
- `ios/Runner/Runner.entitlements` — app group ID
- `ios/Share Extension/Share Extension.entitlements` — app group ID
- `ios/add_share_extension.rb` — bundle ID and team ID
- `android/app/build.gradle.kts` — namespace and application ID
- `android/app/src/main/kotlin/` — moved package from `com/` to `org/`
- `AGENTS.md` — bundle ID reference

## Reference

- Xcode project: `ios/Runner.xcodeproj` (Development Team `FDPGS97G76`)
- Share Extension: `org.savebutton.app.ShareExtension`
- Apple Developer account: `steven@savebutton.com`
- iOS cert private key: `ios-cert-private-key.pem` (gitignored)
- API key: `~/Downloads/AuthKey_F3KU786844.p8` (gitignored)

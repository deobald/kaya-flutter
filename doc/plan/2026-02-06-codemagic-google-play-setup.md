# Codemagic: Google Play Store Setup

## Summary

Complete the Codemagic CI/CD configuration for building and publishing the Save Button Android app (package name `org.savebutton.app`) to Google Play.

## Current State (as of 2026-02-09)

- **iOS pipeline is fully working** — see `doc/plan/2026-02-06-codemagic-app-store-setup.md` (COMPLETE) and `doc/plan/2026-02-07-codemagic-app-store-troubleshooting.md`
- `android/app/build.gradle.kts` is configured to read signing credentials from `android/key.properties` (falls back to debug signing if absent)
- Upload keystore generated at `upload-keystore.jks` (gitignored)
- Credentials saved in `android-signing-credentials.txt` (gitignored):
  - Keystore file: `upload-keystore.jks`
  - Key alias: `org.savebutton.app`
  - Keystore/key password: `T1kWqnxNhLJ3m8bjdzi6tFBrnAND/b02`
  - SHA-256: `C5:FB:18:70:AE:4D:79:C5:37:89:DE:D8:78:84:CE:C5:F0:65:D6:8F:61:6A:7B:31:A2:C6:D4:F0:4C:DD:DC:90`
- `.gitignore` updated to exclude `*.jks`, `*.keystore`, `android/key.properties`, `android-signing-credentials.txt`
- Android signing secrets (`FCI_KEYSTORE`, `FCI_KEYSTORE_PASSWORD`, `FCI_KEY_PASSWORD`, `FCI_KEY_ALIAS`) already added to Codemagic UI in the `android_credentials` group
- `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` added to Codemagic UI in the `android_credentials` group
- **All Android sections in `codemagic.yaml` are now uncommented and active** (build, artifacts, and google_play publishing)

### Related Plan Documents

- `doc/plan/2026-02-06-codemagic-app-store-setup.md` — iOS setup (COMPLETE)
- `doc/plan/2026-02-07-codemagic-app-store-troubleshooting.md` — iOS troubleshooting log with key learnings


## Remaining Steps

### Step 1: Create Google Cloud Project and Service Account (MANUAL - Steven) — COMPLETE

Google Cloud project and service account created. JSON key downloaded.

### Step 2: Create the App in Google Play Console (MANUAL - Steven) — COMPLETE

App listing created in Google Play Console.

### Step 3: Link Service Account to Google Play Console (MANUAL - Steven) — COMPLETE

Service account email invited via **Users and permissions** in Google Play Console with app-level release permissions for Save Button.

Note: The original plan referenced **Settings > API access**, but the current Play Console UI uses **Users and permissions > Invite new users** instead.

### Step 4: Add Google Play Credentials to Codemagic UI (MANUAL - Steven) — COMPLETE

`GCLOUD_SERVICE_ACCOUNT_CREDENTIALS` added to the `android_credentials` group in Codemagic UI.

### Step 5: Uncomment Android Build and Google Play Publishing in codemagic.yaml (AUTOMATED - LLM agent) — COMPLETE

All Android sections uncommented in `codemagic.yaml` on 2026-02-09:
- `android_credentials` environment group
- `PACKAGE_NAME` and `FCI_KEYSTORE_PATH` environment vars
- Android signing (`key.properties`) and `local.properties` setup scripts
- `Build AAB (Android)` script
- APK, AAB, and mapping.txt artifact paths
- `google_play` publishing section (internal track, submit as draft)

### Step 6: Upload Initial AAB to Google Play (MANUAL or AUTOMATED)

Google Play requires that the **first** app bundle be uploaded manually before the API can publish subsequent builds. Options:

**Option A (manual):**
1. Build a release AAB locally: `flutter build appbundle --release`
2. Upload it via Google Play Console > **Production** (or Internal testing) > **Create new release**

**Option B (via CLI after Codemagic builds):**
1. After the first Codemagic build succeeds and produces an AAB artifact, download it
2. Upload via Play Console manually

After the first upload, Codemagic's `google_play` publisher will handle all subsequent uploads automatically.

### Step 7: Verify End-to-End (AUTOMATED - LLM agent)

1. Push a commit to `master`
2. Confirm Codemagic triggers a build
3. Confirm the AAB is built and signed correctly
4. Confirm the AAB is published to the internal track on Google Play

## Files Modified

- `codemagic.yaml` — uncomment `google_play` section, possibly add new environment variable group
- No other file changes expected

## Reference

- Android signing credentials: `android-signing-credentials.txt` (gitignored, local only)
- Upload keystore: `upload-keystore.jks` (gitignored, local only)

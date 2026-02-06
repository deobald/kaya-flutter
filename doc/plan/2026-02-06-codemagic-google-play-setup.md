# Codemagic: Google Play Store Setup

## Summary

Complete the Codemagic CI/CD configuration for building and publishing the Save Button Android app (package name `com.savebutton.app`) to Google Play. The Android upload keystore has already been generated and the `codemagic.yaml` has placeholder `Encrypted(...)` values that need to be replaced with real encrypted secrets.

## Current State

- `codemagic.yaml` exists with an Android build workflow (placeholder encrypted values)
- `android/app/build.gradle.kts` is configured to read signing credentials from `android/key.properties` (falls back to debug signing if absent)
- Upload keystore generated at `upload-keystore.jks` (gitignored)
- Credentials saved in `android-signing-credentials.txt` (gitignored):
  - Keystore file: `upload-keystore.jks`
  - Key alias: `com.savebutton.app`
  - Keystore/key password: `AfCXpetCyp3toshCn+wuoIKujrfhkI8w`
  - SHA-256: `CC:30:1E:9F:D4:B6:82:AB:B1:38:CD:BF:16:50:CC:03:8D:EE:FA:B0:C0:81:F6:31:88:70:4A:9A:82:C6:8F:5E`
- `.gitignore` updated to exclude `*.jks`, `*.keystore`, `android/key.properties`, `android-signing-credentials.txt`


## Steps

### Step 1: Create Google Cloud Project and Service Account (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Have you created the Google Cloud service account and downloaded the JSON key? If not, here are the steps..."

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Create a new project named `Save Button CI` (or similar)
3. Go to **IAM & Admin > Service Accounts**
4. Click **Create Service Account**
   - Name: `codemagic-ci`
   - Click **Create and Continue**
   - Skip the optional role/access steps, click **Done**
5. Click on the newly created service account
6. Go to the **Keys** tab
7. Click **Add Key > Create new key > JSON > Create**
8. Save the downloaded `.json` file securely

### Step 2: Create the App in Google Play Console (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Have you created the Save Button app listing in Google Play Console?"

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. App name: `Save Button`
4. Default language: English
5. App or Game: App
6. Free or Paid: (Steven's choice)
7. Complete the declarations and click **Create app**

### Step 3: Link Service Account to Google Play Console (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Have you linked the Google Cloud service account to Google Play Console?"

1. In Google Play Console, go to **Settings** (gear icon) > **API access**
2. Link the Google Cloud project created in Step 1
3. Find the `codemagic-ci` service account in the list
4. Click **Manage Play Console permissions**
5. Grant these permissions:
   - **App access**: Select **Save Button** (or "All apps")
   - Under **Account permissions**, enable:
     - View app information and download bulk reports
     - Create, edit, and delete draft apps
     - Release apps to testing tracks
     - Manage testing tracks and edit tester lists
6. Click **Invite user** and confirm

### Step 4: Encrypt Secrets into codemagic.yaml (AUTOMATED - LLM agent)

> Requires: path to the service account JSON file from Step 1

Once Steven provides the path to the Google Play service account JSON file:

1. Open the Codemagic web UI for the Save Button app
2. Navigate to the encryption tool (or use `https://codemagic.io/encrypt`)
3. Encrypt each of the following values and capture the `Encrypted(...)` output:
   - **FCI_KEYSTORE**: base64-encoded keystore (`base64 -i upload-keystore.jks`)
   - **FCI_KEYSTORE_PASSWORD**: `AfCXpetCyp3toshCn+wuoIKujrfhkI8w`
   - **FCI_KEY_PASSWORD**: `AfCXpetCyp3toshCn+wuoIKujrfhkI8w`
   - **FCI_KEY_ALIAS**: `com.savebutton.app`
   - **Google Play credentials**: the full contents of the service account JSON file

> When resuming this plan, prompt Steven: "I need to encrypt secrets via the Codemagic web UI. Please go to your Codemagic app settings, find the encryption tool, and we'll encrypt each value together. Alternatively, provide me the Codemagic app ID so I can construct the encryption URL."

4. Update `codemagic.yaml`, replacing each `Encrypted(...)` placeholder in the Android-related vars and `google_play.credentials` with the real encrypted values.

### Step 5: Upload Initial AAB to Google Play (MANUAL or AUTOMATED)

Google Play requires that the **first** app bundle be uploaded manually before the API can publish subsequent builds. Options:

**Option A (manual):**
1. Build a release AAB locally: `flutter build appbundle --release`
2. Upload it via Google Play Console > **Production** (or Internal testing) > **Create new release**

**Option B (via CLI after Codemagic builds):**
1. After the first Codemagic build succeeds and produces an AAB artifact, download it
2. Upload via Play Console manually

After the first upload, Codemagic's `google_play` publisher will handle all subsequent uploads automatically.

### Step 6: Verify End-to-End (AUTOMATED - LLM agent)

1. Push a commit to `master`
2. Confirm Codemagic triggers a build
3. Confirm the AAB is built and signed correctly
4. Confirm the AAB is published to the internal track on Google Play

## Files Modified

- `codemagic.yaml` — replace `Encrypted(...)` placeholders for Android secrets and Google Play credentials
- No other file changes expected

## Reference

- Pariyatti mobile-app `codemagic.yaml` at `/Users/steven/work/pariyatti/mobile-app/codemagic.yaml` is the reference configuration
- Android signing credentials: `android-signing-credentials.txt` (gitignored, local only)
- Upload keystore: `upload-keystore.jks` (gitignored, local only)

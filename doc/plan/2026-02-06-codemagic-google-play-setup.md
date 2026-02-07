# Codemagic: Google Play Store Setup

## Summary

Complete the Codemagic CI/CD configuration for building and publishing the Save Button Android app (package name `org.savebutton.app`) to Google Play.

## Current State

- `codemagic.yaml` exists with Android build workflow; `google_play` publishing is commented out pending setup
- `android/app/build.gradle.kts` is configured to read signing credentials from `android/key.properties` (falls back to debug signing if absent)
- Upload keystore generated at `upload-keystore.jks` (gitignored)
- Credentials saved in `android-signing-credentials.txt` (gitignored):
  - Keystore file: `upload-keystore.jks`
  - Key alias: `org.savebutton.app`
  - Keystore/key password: `T1kWqnxNhLJ3m8bjdzi6tFBrnAND/b02`
  - SHA-256: `C5:FB:18:70:AE:4D:79:C5:37:89:DE:D8:78:84:CE:C5:F0:65:D6:8F:61:6A:7B:31:A2:C6:D4:F0:4C:DD:DC:90`
- `.gitignore` updated to exclude `*.jks`, `*.keystore`, `android/key.properties`, `android-signing-credentials.txt`
- Android signing secrets (`FCI_KEYSTORE`, `FCI_KEYSTORE_PASSWORD`, `FCI_KEY_PASSWORD`, `FCI_KEY_ALIAS`) already added to Codemagic UI in the `android_credentials` group


## Remaining Steps

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

### Step 4: Add Google Play Credentials to Codemagic UI (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Please add the Google Play service account JSON to the Codemagic UI."

1. In the Codemagic app settings, go to **Environment variables**
2. In the `android_credentials` group (or a new `google_play_credentials` group), add:
   - Variable name: `GCLOUD_SERVICE_ACCOUNT_CREDENTIALS`
   - Value: paste the full contents of the service account JSON file
   - Mark as **Secret**

### Step 5: Uncomment Google Play Publishing in codemagic.yaml (AUTOMATED - LLM agent)

Uncomment the `google_play` section in `codemagic.yaml`:

```yaml
      google_play:
        credentials: $GCLOUD_SERVICE_ACCOUNT_CREDENTIALS
        track: internal
        submit_as_draft: true
```

If the credentials were added to a new group, also add that group to the `groups` list.

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

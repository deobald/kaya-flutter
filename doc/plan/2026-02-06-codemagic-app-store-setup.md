# Codemagic: Apple App Store Setup

## Summary

Complete the Codemagic CI/CD configuration for building and publishing the Save Button iOS app (bundle ID `com.savebutton.app`) to the App Store via TestFlight. The `codemagic.yaml` has placeholder `Encrypted(...)` values for iOS that need to be replaced with real encrypted secrets. The Xcode project is already configured with Development Team `Z8C46829M8`.

## Current State

- `codemagic.yaml` exists with an iOS build workflow (placeholder encrypted values)
- Xcode project configured:
  - Bundle ID: `com.savebutton.app`
  - Development Team: `Z8C46829M8`
  - Code signing identity: `iPhone Developer`
  - Share Extension bundle ID: `com.savebutton.app.ShareExtension`
- Apple Developer account (`steven@savebutton.com`) is pending verification
- No App Store Connect API key exists yet
- No distribution certificate or provisioning profiles exist yet


## Steps

### Step 1: Wait for Apple Developer Account Verification (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Has your Apple Developer account (steven@savebutton.com) been verified and do you have access to App Store Connect yet?"

The Apple Developer Program enrollment must be fully processed before any of the subsequent steps can proceed. This typically takes 24-48 hours but may take longer.

### Step 2: Create an App Store Connect API Key (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Please create an App Store Connect API key. Here are the exact steps..."

1. Go to [App Store Connect](https://appstoreconnect.apple.com) and sign in with `steven@savebutton.com`
2. Click **Users and Access** in the top navigation
3. Click the **Integrations** tab, then **App Store Connect API** in the sidebar
4. Click **Generate API Key** (may need to agree to terms first)
5. Name: `Codemagic CI`
6. Access: **Admin** (required for creating certificates and provisioning profiles)
7. Click **Generate**
8. Record these values:
   - **Issuer ID** (shown at the top of the page, shared across all keys)
   - **Key ID** (shown in the table row for the new key)
9. **Download the `.p8` private key file** — Apple only allows downloading it **once**

Steven must provide:
- The Issuer ID
- The Key ID
- The path to the downloaded `.p8` file

### Step 3: Generate iOS Certificate Private Key (AUTOMATED - LLM agent)

> Requires: App Store Connect API key from Step 2

Generate a private key for iOS distribution certificate:

```bash
openssl genrsa -out /Users/steven/work/deobald/kaya-flutter/ios-cert-private-key.pem 2048
```

This key will be used by Codemagic to create and manage iOS distribution certificates via the App Store Connect API.

### Step 4: Register Bundle IDs and Create Signing Files (AUTOMATED - LLM agent)

> Requires: API key credentials from Step 2, private key from Step 3

Using the `app-store-connect` CLI:

```bash
# Register the main app bundle ID (if not already registered)
app-store-connect bundle-ids create \
  --identifier "com.savebutton.app" \
  --name "Save Button" \
  --platform IOS \
  --issuer-id "$ISSUER_ID" \
  --key-id "$KEY_ID" \
  --private-key "@file:$P8_PATH"

# Register the Share Extension bundle ID
app-store-connect bundle-ids create \
  --identifier "com.savebutton.app.ShareExtension" \
  --name "Save Button Share Extension" \
  --platform IOS \
  --issuer-id "$ISSUER_ID" \
  --key-id "$KEY_ID" \
  --private-key "@file:$P8_PATH"

# Fetch/create signing files (certificate + provisioning profile) for the main app
app-store-connect fetch-signing-files "com.savebutton.app" \
  --type IOS_APP_STORE \
  --certificate-key "@file:ios-cert-private-key.pem" \
  --create \
  --issuer-id "$ISSUER_ID" \
  --key-id "$KEY_ID" \
  --private-key "@file:$P8_PATH"

# Fetch/create signing files for the Share Extension
app-store-connect fetch-signing-files "com.savebutton.app.ShareExtension" \
  --type IOS_APP_STORE \
  --certificate-key "@file:ios-cert-private-key.pem" \
  --create \
  --issuer-id "$ISSUER_ID" \
  --key-id "$KEY_ID" \
  --private-key "@file:$P8_PATH"
```

### Step 5: Create the App in App Store Connect (AUTOMATED - LLM agent)

> Requires: API key credentials from Step 2, Bundle ID from Step 4

Using the `app-store-connect` CLI:

```bash
app-store-connect apps create \
  --name "Save Button" \
  --primary-locale "en-US" \
  --bundle-id-id "$BUNDLE_ID_RESOURCE_ID" \
  --sku "com.savebutton.app" \
  --issuer-id "$ISSUER_ID" \
  --key-id "$KEY_ID" \
  --private-key "@file:$P8_PATH"
```

Record the **Apple ID** (numeric) returned — this is needed for `APP_STORE_APPLE_ID` in `codemagic.yaml`.

### Step 6: Encrypt Secrets into codemagic.yaml (AUTOMATED - LLM agent)

> Requires: all credentials from previous steps

Encrypt the following values via the Codemagic web UI encryption tool and update `codemagic.yaml`:

> When resuming this plan, prompt Steven: "I need to encrypt iOS secrets via the Codemagic web UI. Please navigate to your Codemagic app's encryption tool."

Values to encrypt:
- **APP_STORE_CONNECT_ISSUER_ID**: the Issuer ID from Step 2
- **APP_STORE_CONNECT_KEY_IDENTIFIER**: the Key ID from Step 2
- **APP_STORE_CONNECT_PRIVATE_KEY**: contents of the `.p8` file from Step 2
- **CERTIFICATE_PRIVATE_KEY**: contents of `ios-cert-private-key.pem` from Step 3

Update `codemagic.yaml`:
- Replace all iOS-related `Encrypted(...)` placeholders with the real encrypted values
- Add `APP_STORE_APPLE_ID` var with the numeric Apple ID from Step 5
- Under `app_store_connect` publishing, replace `api_key`, `key_id`, `issuer_id` placeholders

### Step 7: Configure TestFlight Beta Group (MANUAL - Steven)

> When resuming this plan, prompt Steven: "Do you want to create a TestFlight beta group? If so, what should it be named and who should be in it?"

1. In App Store Connect, go to the **Save Button** app > **TestFlight** > **Internal Testing**
2. Create a group (e.g., "Beta Testers")
3. Add testers by email
4. Update `codemagic.yaml` to reference the group name under `beta_groups`

### Step 8: Update .gitignore for iOS Secrets (AUTOMATED - LLM agent)

Add iOS-specific secret files to `.gitignore`:
- `ios-cert-private-key.pem`
- `*.p8`

### Step 9: Verify End-to-End (AUTOMATED - LLM agent)

1. Push a commit to `master`
2. Confirm Codemagic triggers a build
3. Confirm the IPA is built and signed correctly
4. Confirm the IPA is uploaded to TestFlight
5. Confirm the build appears in App Store Connect

## Files Modified

- `codemagic.yaml` — replace `Encrypted(...)` placeholders for iOS secrets and App Store Connect publishing
- `.gitignore` — add `ios-cert-private-key.pem`, `*.p8`
- No other file changes expected

## Reference

- Pariyatti mobile-app `codemagic.yaml` at `/Users/steven/work/pariyatti/mobile-app/codemagic.yaml` is the reference configuration
- Xcode project: `ios/Runner.xcodeproj` (Development Team `Z8C46829M8`)
- Share Extension: `com.savebutton.app.ShareExtension`
- Apple Developer account: `steven@savebutton.com`

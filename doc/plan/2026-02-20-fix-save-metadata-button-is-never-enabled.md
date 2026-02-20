# Fix: "Save Metadata" button is never enabled

## Context

On the PreviewScreen, when a user types into the Tags or Note text fields, the "Save Metadata" button should become enabled. Currently it stays disabled because the `onChanged` callbacks set `_metadataChanged = true` without calling `setState()`, so the widget never rebuilds and the button's `onPressed` stays `null`.

## Root Cause

`lib/features/everything/screens/preview_screen.dart` lines 349 and 360:

```dart
onChanged: (_) => _metadataChanged = true,   // tags
onChanged: (_) => _metadataChanged = true,   // note
```

These must be wrapped in `setState()` to trigger a rebuild.

## Changes

### 1. Add tests for `FileStorageService.saveMeta` and `loadMetaForAnga`

**File:** `test/features/anga/services/file_storage_service_test.dart`

New test group for metadata operations:
- `saveMeta` creates a TOML file in the meta directory with correct content
- `loadMetaForAnga` returns the most recent metadata for a given anga
- `loadMetaForAnga` returns null when no metadata exists
- Multiple metadata files for the same anga: most recent is returned

### 2. Fix the `onChanged` callbacks in `_buildMetadataSection`

**File:** `lib/features/everything/screens/preview_screen.dart`

Wrap both `onChanged` callbacks in `setState()`:
```dart
onChanged: (_) => setState(() => _metadataChanged = true),
```

## Verification

1. `flutter test` — all tests pass
2. `flutter analyze` — no new warnings

# Fix: Sharing a URL should share the URL text, not the `.url` file

## Context

When a user shares a bookmark from the PreviewScreen, the `.url` file itself is shared via `Share.shareXFiles`. Most receiving apps don't understand `.url` files. Instead, the URL text should be shared so receiving apps can display a social preview, open it, etc.

Notes already work correctly because their `.md` file content is readable text.

## Root Cause

`preview_screen.dart` line 408-410:

```dart
Future<void> _shareAnga(Anga anga) async {
  await Share.shareXFiles([XFile(anga.path)]);
}
```

This always shares the raw file, regardless of anga type.

## Fix

For bookmarks, use `Share.share(url)` to share the URL as plain text. For all other anga types, continue using `Share.shareXFiles` to share the file.

## Files Modified

- `lib/features/everything/screens/preview_screen.dart` — `_shareAnga` method

## Verification

Presentation-only change; no tests required per PLAN.md.

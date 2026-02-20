# Fix: Cupertino Icons not used correctly

## Context

On iOS, the user should see familiar iOS-native icons. The `cupertino_icons` package is already a dependency but is not used anywhere. All icons currently use Material Design icons.

## Changes

Use `Platform.isIOS` to select the appropriate icon on each platform. On iOS, use `CupertinoIcons`; on Android, keep the existing Material icons.

### Icons to change

| Location | Material Icon | Cupertino Icon |
|----------|--------------|----------------|
| preview_screen.dart: Share button | `Icons.share` | `CupertinoIcons.share_up` |
| preview_screen.dart: Download button | `Icons.download` | `CupertinoIcons.cloud_download` |
| everything_screen.dart: Add button | `Icons.add` | `CupertinoIcons.add_circled_solid` |
| everything_screen.dart: Search prefix | `Icons.search` | `CupertinoIcons.search` |
| anga_tile.dart: Bookmark icon | `Icons.bookmark` | `CupertinoIcons.bookmark_fill` |
| anga_tile.dart: PDF icon | `Icons.picture_as_pdf` | `CupertinoIcons.doc_richtext` |

### Files modified

- `lib/features/everything/screens/preview_screen.dart`
- `lib/features/everything/screens/everything_screen.dart`
- `lib/features/anga/widgets/anga_tile.dart`

## Verification

Presentation-only change; no tests required per PLAN.md.

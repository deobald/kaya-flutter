# Refactor: Extract KayaIcon widget

## Context

Platform-specific icon selection (`Platform.isIOS ? CupertinoIcons.x : Icons.y`) is duplicated across 4 files. Extract into a single `KayaIcon` class so all icons are routed through one place.

## Design

`lib/core/widgets/kaya_icon.dart` exposes static `IconData` getters that return the appropriate icon per platform. Every `Icons.` and `CupertinoIcons.` call across the app is replaced with `KayaIcon.x`.

Icons that have no Cupertino counterpart simply return the Material icon on both platforms.

## Files Modified

- `lib/core/widgets/kaya_icon.dart` — new file
- `lib/core/widgets/error_alert_icon.dart`
- `lib/core/widgets/cloud_status_icon.dart`
- `lib/features/anga/widgets/anga_tile.dart`
- `lib/features/errors/screens/errors_list_screen.dart`
- `lib/features/everything/screens/everything_screen.dart`
- `lib/features/everything/screens/preview_screen.dart`
- `lib/features/account/screens/account_screen.dart`
- `lib/features/account/screens/troubleshooting_screen.dart`

## Verification

Presentation-only refactoring; no tests required per PLAN.md.
`flutter test` and `flutter analyze` must pass.

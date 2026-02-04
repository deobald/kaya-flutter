# Kaya Design

Kaya mobile apps borrow all their design principles from the [Material Design Guidelines](https://m2.material.io/design/guidelines-overview).

As a fallback, should Material Design not provide a guideline, sensible design guidelines from the [GNOME HIG](https://developer.gnome.org/hig/) may be used, as they pertain to mobile phones and tablets.

## Icons

Symbolic icons should always use Flutter's iOS-specific icons available from the `cupertino_icons` package or Android-specific icons from `uses-material-design: true` in [@pubspec.yaml](./pubspec.yaml). Prefer iOS-specific and Android-specific icons, where possible.

Where Material Design or Cupertino Icons are not available, use the [GNOME HIG icons](https://developer.gnome.org/hig/guidelines/ui-icons.html). 
All GNOME HIG icons used are Creative Commons Zero 1.0 Universal.

## UI Rules

**Colors**: Use theme system, never hardcoded values

**Accessibility**:
- Minimum [48dp/44pt] touch targets
- Alt text/labels required for icons (use `null` only for decorative)
- Don't rely solely on color - pair with icons/text
- Loading indicators must have labels for screen readers

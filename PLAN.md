# Kaya Flutter Implementation Plan

## Overview

This plan outlines the implementation of Kaya, a local-first Flutter mobile app for iOS/iPadOS and Android that allows users to save bookmarks, notes, and files via the share sheet, then search and browse them. Data syncs with a Kaya Server when online.

---

## Phase 1: Project Setup & Foundation

### 1.1 Flutter Project Initialization
- Create Flutter project with Bundle ID `ca.deobald.Kaya` (iOS) and package name `ca.deobald.Kaya` (Android)
- Configure for iOS, iPadOS, and Android targets only (remove web, desktop)
- Set up `pubspec.yaml` with required dependencies

### 1.2 Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.6.1
  riverpod_annotation: ^2.6.1
  freezed_annotation: ^3.1.0
  logger: ^2.5.0
  shared_preferences: ^2.3.5
  path_provider: ^2.1.5
  share_handler: # for receiving shared content
  share_plus: # for sharing content out
  fuzzy_bolt: # for search
  flutter_pdf_text: # for PDF text extraction
  flutter_pdfview: # for PDF rendering
  http: # for API calls
  toml: # for metadata parsing
  url_launcher: # for opening URLs
  cupertino_icons: ^1.0.8
  video_player: # for video preview
  flutter_secure_storage: # for encrypted password storage
  connectivity_plus: # for detecting online/offline state
  
dev_dependencies:
  build_runner:
  riverpod_generator:
  freezed:
  flutter_launcher_icons:
```

### 1.3 Project Structure
```
lib/
├── main.dart
├── core/
│   ├── routing/
│   │   └── router.dart
│   ├── services/
│   │   ├── logger_service.dart
│   │   └── connectivity_service.dart
│   ├── utils/
│   │   └── datetime_utils.dart
│   └── widgets/
│       └── error_alert_icon.dart
├── features/
│   ├── anga/
│   │   ├── models/
│   │   │   ├── anga.dart
│   │   │   └── anga_type.dart
│   │   ├── services/
│   │   │   ├── anga_repository.dart
│   │   │   └── file_storage_service.dart
│   │   └── widgets/
│   │       └── anga_tile.dart
│   ├── meta/
│   │   ├── models/
│   │   │   └── anga_meta.dart
│   │   └── services/
│   │       └── meta_repository.dart
│   ├── search/
│   │   ├── services/
│   │   │   └── search_service.dart
│   │   └── widgets/
│   │       └── search_bar.dart
│   ├── sync/
│   │   ├── services/
│   │   │   └── sync_service.dart
│   │   └── controllers/
│   │       └── sync_controller.dart
│   ├── share/
│   │   ├── services/
│   │   │   └── share_receiver_service.dart
│   │   └── controllers/
│   │       └── share_handler_controller.dart
│   ├── account/
│   │   ├── models/
│   │   │   └── account_settings.dart
│   │   ├── services/
│   │   │   └── account_repository.dart
│   │   └── screens/
│   │       ├── account_screen.dart
│   │       └── troubleshooting_screen.dart
│   ├── errors/
│   │   ├── models/
│   │   │   └── app_error.dart
│   │   ├── services/
│   │   │   └── error_service.dart
│   │   └── screens/
│   │       └── errors_list_screen.dart
│   └── everything/
│       ├── screens/
│       │   ├── everything_screen.dart
│       │   ├── preview_screen.dart
│       │   └── add_screen.dart
│       └── controllers/
│           └── everything_controller.dart
```

### 1.4 App Icon Generation
- Convert `doc/design/icon.svg` to PNG at all required resolutions
- Create light/dark mode variants by adjusting background color
- Configure `flutter_launcher_icons` in pubspec.yaml

---

## Phase 2: Core Models & Services

### 2.1 Anga Model
```dart
@freezed
class Anga {
  // filename: "2026-01-27T171207-www-deobald-ca.url"
  // type: bookmark, note, or file
  // path: full path to file
  // createdAt: parsed from filename
}
```

**Anga Types:**
- **Bookmark** (`.url`): Microsoft Windows-style URL file
- **Note** (`.md` with `-note.md` suffix): Markdown text content
- **File**: Any other file type (images, PDFs, videos, etc.)

**Duplicate Handling:** Users may bookmark the same URL multiple times; each creates a separate anga with its own timestamp.

### 2.2 Metadata Model
```dart
@freezed
class AngaMeta {
  // metaFilename: the .toml filename (includes timestamp)
  // angaFilename: references anga
  // tags: List<String>
  // note: String (user's note about the anga)
}
```

**Multiple Metadata Files:** Multiple `.toml` files can reference the same anga. When displaying in Preview Screen, show only the most recent metadata. All metadata files are indexed for search.

### 2.3 File Storage Service
- Root directory: `getApplicationSupportDirectory() + "/kaya"`
- Subdirectories: `/anga`, `/meta`, `/cache`
- Filename format: `YYYY-MM-DDTHHMMSS-{descriptor}.{ext}`
- Handle nanosecond collision format: `YYYY-MM-DDTHHMMSS_SSSSSSSSS-{descriptor}.{ext}`

### 2.4 Logger Service
- Use `logger` package
- Log to STDOUT and file simultaneously
- Log file stored in app support directory for user access
- Log significant events: shares, syncs, errors

### 2.5 Error Service
- Track errors and warnings in memory (do not persist across app restarts; log file preserves history)
- Provide list to UI for display
- Clear mechanism for acknowledged errors

### 2.6 Connectivity Service
- Monitor network connectivity state
- Trigger sync when device comes back online (if credentials configured)

---

## Phase 3: Share Sheet Integration

### 3.1 Share Handler Setup
- Configure `share_handler` to receive all content types
- Register for: text, URLs, images, videos, files

### 3.2 Content Processing
- **URL detection**: Create `.url` file with format:
  ```
  [InternetShortcut]
  URL=https://example.com/
  ```
  Filename: `{timestamp}-{sanitized-domain}.url`
  - Domain only: exclude paths, query strings, and anchors
  - Sanitize: replace `.` and special characters with `-`
  - Example: `https://www.example.com/path?q=1#anchor` → `www-example-com.url`
  
- **Text (non-URL)**: Create `-note.md` file with verbatim content
  Filename: `{timestamp}-note.md`

- **Files (images, PDFs, videos, etc.)**: Copy file with original extension
  Filename: `{timestamp}-{original-filename}.{ext}`

### 3.3 Offline Support
- Shares work fully offline
- New angas saved locally immediately
- Synced to server when connectivity returns

### 3.4 Cold Start Sharing (Android)
- When app is killed and receives a share intent, Android launches the app with intent data
- Use `ShareHandlerPlatform.instance.getInitialSharedMedia()` on app init to check for pending shares
- Note: Some Android ROMs with aggressive battery optimization may prevent app launch; this is a system-level issue affecting all apps and requires user to disable battery optimization if problems occur

---

## Phase 4: Everything Screen (Main UI)

### 4.1 Layout
- Hamburger menu (drawer) with:
  - "Everything" → main screen
  - "Account" → account settings
- Header with:
  - Menu button
  - Plus button (add bookmark/note)
  - Error alert icon (orange, visible when errors exist)
- Search bar at top
- Responsive tile grid:
  - 2 columns: small phones
  - 3 columns: large phones, landscape orientation
  - 4 columns: tablets

### 4.2 Tile Display
- Reverse chronological order (default)
- Ranked by score when searching
- Tile content by type:
  - **Bookmark**: favicon from synced cache only (do not fetch from web)
  - **Note**: text preview (larger font for shorter content)
  - **Image**: thumbnail of image
  - **PDF**: PDF icon
  - **Video**: video thumbnail or icon
  - **Other**: file extension badge

### 4.3 Navigation
- Tap tile → Preview Screen

---

## Phase 5: Search

### 5.1 Search Implementation
- Use `fuzzy_bolt` with `searchWithTextProcessing`
- Options: `enableStemming: true`, `removeStopWords: true`
- Incremental filtering as user types
- Debounce search input by 100ms for performance with large collections

### 5.2 Search Corpus
- Anga filenames
- Anga file contents (notes, bookmarks)
- Cached webpage content (`/kaya/cache/{bookmark}/`) - synced from server
- PDF text content (via `flutter_pdf_text`)
- Metadata tags and notes (`/kaya/meta/`) - all metadata files, not just most recent

### 5.3 Indexing Strategy
- Build search index on app start
- Update index when new anga added or synced
- Cache PDF text extraction results

---

## Phase 6: Preview Screen

### 6.1 Content Display
- **Bookmarks**: Display cached HTML from `/kaya/cache` if available; otherwise fetch from web for display only (do not cache locally)
- **PDFs**: Render inline with `flutter_pdfview`
- **Images**: Display inline
- **Videos**: Do not auto-play; require user tap to start. Play with sound by default.
- **Notes/Text**: Display formatted content

### 6.2 Bookmark-Specific Features
- Show original URL
- "Visit Original Page" button → opens in browser

### 6.3 Metadata Editing
- Tags input field (add/remove tags)
- Note text area
- Display most recent metadata for this anga
- Save button creates new `.toml` file in `/kaya/meta/` with current timestamp

### 6.4 Actions
- **Share**: Use `share_plus` to share the anga file
- **Download**: 
  - Android: Save to standard Downloads directory
  - iOS: Use Files app integration

---

## Phase 7: Add Bookmark/Note Screen

### 7.1 Interface
- Single text input field
- URL detection → save as bookmark
- Non-URL text → save as note
- Save and Cancel buttons

### 7.2 Processing
- Same logic as share handler
- Navigate back to Everything screen on save

---

## Phase 8: Account & Settings

### 8.1 Account Screen Fields
- Kaya Server URL (default: "https://kaya.town")
- Email
- Password (encrypted at rest with `flutter_secure_storage`)

### 8.2 Persistence
- Use `shared_preferences` for server URL and email
- Use `flutter_secure_storage` for password encryption

### 8.3 Actions
- **Test Connection**: Make authenticated GET request to `/api/v1/:user_email/anga`
- **Force Sync**: Trigger immediate sync
- **Troubleshooting**: Navigate to troubleshooting screen

---

## Phase 9: Troubleshooting Screen

### 9.1 Log Display
- Show application log contents
- Scrollable view of recent log entries

### 9.2 Send Logs
- "Send To Developer" button
- Attach log file to email
- Recipient: steven+kaya@deobald.ca
- Use device's native email client

---

## Phase 10: Sync Service

### 10.1 Sync Logic (from ADR-0002 and sync.rb)
- Compare local files with server files (by filename)
- Upload missing files to server (anga, meta)
- Download missing files from server (anga, meta, cache)
- Cache is download-only (mobile app cannot create cache content)
- **Conflict handling**: If a filename exists both locally and remotely with different content, do not sync that file. Log an error and show alert to user.

### 10.2 API Endpoints
```
GET  /api/v1/:email/anga           → list anga files
GET  /api/v1/:email/anga/:filename → download anga file
POST /api/v1/:email/anga/:filename → upload anga file

GET  /api/v1/:email/meta           → list meta files
GET  /api/v1/:email/meta/:filename → download meta file
POST /api/v1/:email/meta/:filename → upload meta file

GET  /api/v1/:email/cache                        → list cached bookmarks
GET  /api/v1/:email/cache/:bookmark              → list files in cache
GET  /api/v1/:email/cache/:bookmark/:filename    → download cache file
```

Note: Ignore `/smart` endpoint for now (not implemented on server).

### 10.3 Authentication
- HTTP Basic Auth with email and password

### 10.4 Scheduling
- Run sync every 60 seconds (when credentials configured and online)
- Trigger sync when device comes back online
- Silent sync (no logging) when nothing to transfer
- Log uploads, downloads, and errors
- Show error alert icon on sync failure

---

## Phase 11: Testing

### 11.1 Model Tests
- Anga parsing and creation
- Metadata parsing and creation
- Filename generation with timestamps
- URL file format parsing
- Finding most recent metadata for an anga

### 11.2 Service Tests
- File storage operations
- Search indexing and querying
- Sync logic (upload/download decisions)
- Share content processing

### 11.3 Edge Cases
- Filename collisions (nanosecond resolution)
- Large files
- Network failures during sync
- Invalid/malformed data
- Offline operation

---

## Phase 12: Polish & Platform-Specific

### 12.1 Platform Icons
- Use `cupertino_icons` for iOS
- Use Material icons for Android

### 12.2 Accessibility
- Minimum 48dp/44pt touch targets
- Alt text for all icons
- Screen reader labels for loading states

### 12.3 Theming
- Follow Material Design guidelines
- Support light/dark mode



# Plan: Search via 'words' instead of 'cache'

**Date:** 2026-02-04

## Summary

Replace the full cache download (entire cached webpages) with two changes:
1. **Only download favicons** from cache (for tile display)
2. **Download 'words'** (plaintext extracted text) for search indexing

This reduces network usage significantly by avoiding downloading full webpage caches to mobile devices.

## ADRs Referenced

- [ADR-0002: Service Sync](../arch/adr-0002-service-sync.md) — defines the `/words/` API routes
- [ADR-0004: Full Text Search](../arch/adr-0004-full-text-search.md) — defines the words directory structure

## Files Modified

1. **`lib/features/anga/services/file_storage_service.dart`** — Add `wordsPath`, `ensureDirectories()` update, and words CRUD methods
2. **`lib/features/sync/services/sync_service.dart`** — Replace `_syncCache` with `_syncFavicons` (favicon-only) + `_syncWords` (new)
3. **`lib/features/search/services/search_service.dart`** — Use words plaintext instead of cached HTML for search
4. **`lib/features/everything/screens/preview_screen.dart`** — Use words plaintext for bookmark preview

## Changes

### FileStorageService

- Add `wordsPath` property and create directory on init
- Add `listWordsAngas()`, `listWordsFiles()`, `saveWordsFile()`, `getWordsText()`
- `getWordsText()` reads all plaintext from `/kaya/words/{anga}/` for a given anga filename

### SyncService

- `_syncCache` becomes `_syncFavicons`: only downloads favicon files from cache, not full HTML
- New `_syncWords`: downloads plaintext from `/api/v1/:email/words` (2-level directory, download-only)
- `SyncResult` updated: `cacheDownloaded` renamed to `faviconDownloaded`, `wordsDownloaded` added

### SearchService

- `_buildSearchText()`: replaces cached HTML stripping with reading words plaintext
- Now works for any anga with words (bookmarks, PDFs, etc.), not just bookmarks
- `_stripHtml` removed (no longer needed)

### PreviewScreen

- Bookmark preview uses words plaintext instead of cached HTML

---

## Sub-task: Don't hit the API unless a cached favicon or searchable 'words' text is missing

**Date:** 2026-02-04

### Problem

Every sync cycle, `_syncFavicons` and `_syncWords` hit the top-level index endpoints and then the per-entry sub-indexes, even when the local app already has everything it needs. This is wasteful.

### Changes

#### FileStorageService

- Add `hasFaviconOrMarker(bookmarkName)` — returns true if a favicon file OR a `.nofavicon` marker exists in the cache directory for that bookmark
- Add `createNoFaviconMarker(bookmarkName)` — creates a `.nofavicon` turd file in the cache directory for that bookmark

#### SyncService: `_syncFavicons`

- After fetching the top-level `/cache` index, skip any bookmark where `hasFaviconOrMarker()` returns true
- For remaining bookmarks, fetch the sub-index and download favicon files
- If no favicon files exist in the sub-index, call `createNoFaviconMarker()` so we don't re-check next sync

#### SyncService: `_syncWords`

- After fetching the top-level `/words` index, skip any anga that already exists locally (i.e. `localAngas.contains(anga)`)
- Only fetch sub-indexes and download files for new angas

---

## Bug Fix: Search index not rebuilt after words sync

**Date:** 2026-02-04

### Problem

After words files were downloaded during sync, the search index was not rebuilt. The search corpus still contained stale (empty) words data for those angas, so searches against words content never matched.

### Root Cause

In `SyncController.sync()`, the `angaRepositoryProvider.notifier.refresh()` was only called when `angaDownloaded > 0 || metaDownloaded > 0`. When only words were downloaded (no new angas or meta), the refresh was skipped, so the `searchServiceProvider` was never invalidated and `buildIndex()` was never re-run with the new words.

### Fix

Added `result.wordsDownloaded > 0` to the refresh condition in `sync_service.dart:758`:

```dart
if (result.angaDownloaded > 0 ||
    result.metaDownloaded > 0 ||
    result.wordsDownloaded > 0) {
  ref.read(angaRepositoryProvider.notifier).refresh();
}
```

This ensures the search index is rebuilt after words are downloaded, making the new words content searchable.

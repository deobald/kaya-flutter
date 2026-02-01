# Guide for LLMs

This repository contains a Flutter application with iOS, iPadOS, and Android (both phone and tablet) as the only intended target platforms.

The app will be named "Kaya", to the user. The Bundle ID (Apple/iOS) and Package Name (Android) will be `ca.deobald.Kaya`.


## Architecture

The Flutter app should be laid out cleanly and make heavy use of [Riverpod](https://riverpod.dev/), as per the example available in [@riverpod_app](../riverpod_app/).

Read the ADRs in [@arch](./doc/arch/).

### Object Model

Use both model objects and service objects to organize the majority of code, keeping widgets lean and stateless. Try to push as much "business logic" into model objects as possible to reduce their dependencies and to avoid complicated setup/teardown/mocks/etc. in tests. See "Testing".

### Testing

The Flutter app should rely on a simple test suite that tests the application's behaviour through model objects, as much as possible. Include happy path tests and common edge cases when testing service objects.

### Logging

Uses the `logger` package. Log to both STDOUT and a log file, for ease of debugging in development and in release. Log when any significant event occurs. This includes human-triggered messages from the frontend, errors, non-empty file sync events, and so on.

The user should be able to see the mobile app logs with a "Troubleshooting" option under their Account.

### Errors

Errors must be logged and should present the user with an orange "alert" notification icon on the screen header, which they can click to view a list of errors and warnings.

### Bookmarks

Bookmark angas will follow the file format `/kaya/anga/2026-01-27T171207-www-deobald-ca.url`, where the `www-deobald-ca` portion is the domain and subdomains in the URL, with special characters and periods (`.`) turned into hyphens (`-`). Bookmarks are created by clicking the plugin's Toolbar Button.

Bookmarks are saved as `.url` files which have the format:

```
[InternetShortcut]
URL=https://perkeep.org/
```

See also: [@adr-0001-core-concept.md](./doc/arch/adr-0001-core-concept.md).

### Notes

Note angas will follow the format `/kaya/anga/2025-01-24T161204-note.md`. Notes contain the text which create them, verbatim.

See also: [@adr-0001-core-concept.md](./doc/arch/adr-0001-core-concept.md).

### Files

Anga which are neither Bookmarks nor Notes are just regular files. They follow the format `/kaya/anga/2025-01-24T161204-my-original-filename.ext`, where `ext` is the original file extension.

See also: [@adr-0001-core-concept.md](./doc/arch/adr-0001-core-concept.md).


## Share Sheet

The primary UX is to "share" a bookmark, text, snippet, quote, message, image, or file with the Kaya app, which means the user will not usually have the app open.

Use the [`share_handler`](https://pub.dev/packages/share_handler) package. The Kaya Share Sheet should be registered to handle any type of text, images, video, or file. When receiving text, create a `.md` note with the text contents. When receiving a URL, create a Microsoft Windows-style `.url` file. When receiving an image, video, or file, create a file with the standard file extension for that file type / mime type.


## Search

The secondary UX is to search from within the Kaya app. Anything shared to Kaya is saved as an "anga" (component) and displayed to the user as a tile in the Everything Screen. At the top of the Everything Screen is a search bar.

This search will offer incremental search over all the files in `/kaya`, inside the `getApplicationSupportDirectory()` root, including contents of files in `/kaya/anga` and metadata and tags found in `/kaya/meta`. As the user types, the search filters all anga (tiles). Use the `fuzzy_bolt` package for search with `searchWithTextProcessing`, setting `enableStemming` and `removeStopWords` set to `true` for the most natural fuzzy search experience.

Search must:

* match against the contents of `/kaya/cache/{bookmark}` directories, to match any given bookmark against the search query
* match against the contents of PDF files within `/kaya/anga/` using the `flutter_pdf_text` package


## Application

Follow the design instructions from [@README.md](./doc/design/README.md).

### Icon

Use the SVG [@icon](./doc/design/icon.svg) as an icon, rendered to PNG at all relevant resolutions where required. Create light and dark mode variants which only adjust the background color/tint.

### UI

When the app is opened, it should present the user with an "Everything" interface similar to that found in the [@kaya-server](../kaya-server/) UI/view layer:

* hamburger menu in the upper-left with these menu items:
  * "Everything" => goes to the main screen
  * "Account" => goes to the account screen
* plus button to bring up an "add bookmark/note" screen
* "Search" textbox
* grid of bookmark/note/file tiles, 2 or 3 tiles wide, depending on the size/resolution the screen

The UI defaults to the "Everything" screen

### UI: Header

The header, containing hamburger menu and "plus" icon, is visible on the main (Everything) screen. Beside the "plus" icon, any application errors are alerted to the user with an orange "alert" icon that the user may click to view a list of errors and warnings. See "Errors".

### UI: Everything Screen

The main screen of the application. 

**Search:** Put a "search" textbox at the top of the screen. As the user types, the search filters all anga (tiles). Order result tiles from highest to lowest score. See "Search".

**Tiles:** A reverse-chronological (or ranked/scored, when search is active) grid of tiles, 2 or 3 tiles wide, will be visible under the Search bar. It should be 2 tiles wide on smaller phones and 3 tiles wide on larger phones or when any phone is in landscape orientation. On tablets, it should be 4 tiles wide, identical to the `kaya-server` web UI. Clicking any tile (anga) will open the Preview Screen for the corresponding anga/file. Bookmark tiles should display the favicon of the website URL from the corresponding `.url` file. Other files should display their contents on the tile, if possible. Shorter text documents should display in larger text, to avoid excessive whitespace.

### UI: Preview Screen

When a user clicks on a tile (anga) on the Everything screen, it brings up a Preview of that anga. The Preview view in [@kaya-server](../kaya-server/) will be informative to this design.

The Preview Screen should:

* display the contents of the file, if possible
  * bookmarks (`.url`) should display the cached webpage from `/kaya/cache` inline, if available, or download the website from the internet, if not
  * PDFs should render inline using the `flutter_pdfview` package
  * images and videos should render inline
* display the original URL, in the case of bookmarks
* have a "Visit Original Page" button, in the case of bookmarks
* show the user text boxes to enter Tags or a Note, which will be saved as metadata pointing to the current anga/tile, based on [@adr-0003-metadata.md](./doc/arch/adr-0003-metadata.md)
* show the user "Share" and "Download" buttons
  * "Share": using the `share_plus` package, open a share sheet and send the file representing this anga (`/kaya/anga/{somefile}`) to the selected application
  * "Download": download the file representing this anga to the device's regular (non-sandboxed) filesystem, in the standard "Downloads" directory

### UI: Add Bookmark/Note Screen

Contains a textbox for the user to enter a URL or text note. Below the text box are "Save" and "Cancel" buttons.

Do not include the drag-n-drop file drop target which exists in the kaya-server web UI.

### UI: Account Screen

If the user chooses "Account" from the hamburger menu, they are taken to the Account Screen. The Account Screen provides the user with 3 fields:

* Kaya Server (default: "https://kaya.town")
* Email
* Password

These 3 fields should be saved as the user's preferences, with the `shared_preferences` package. The password should be encrypted at rest.

There should be a "Test Connection" button, which confirms for the user that a Basic HTTP Auth connection to one of the server's `GET` API routes can be made successfully.

There should be a "Force Sync" button which forces a sync. See "Sync".

There should be also a HIG-compliant "Troubleshooting" button to drill down into the Troubleshooting Screen.

### UI: Troubleshooting Screen

On the troubleshooting screen, the user can view the application logs. There is a button "Send To Developer" to send the application logs, as an email attachment, to steven+kaya@deobald.ca, using the device's built-in email client.

### Saving Share Data

All text and files ("anga") shared with Kaya, including bookmarks, text, images, PDFs, videos, etc., should be saved to `/kaya/anga/`, in the format described in [@adr-0001-core-concept.md](./doc/arch/adr-0001-core-concept.md).

All metadata ("meta") messages should be saved to `/kaya/meta/`, in the format described in [@adr-0003-metadata.md](./doc/arch/adr-0003-metadata.md).

### Saving Bookmarks

When a URL (bookmark) is shared with Kaya, it should be saved as a Microsoft Windows-style `.url` file. See "Bookmarks" in this document.

### Saving Text

When text (a note, quote, or snippet) is shared with Kaya, it should be saved as a Markdown file ("note") with a suffix of `-note.md`.

### Saving Images, PDFs, and Other Files

When an image, PDF, video, or other file is shared with Kaya, it should be saved with its normal extension, as per its mime type, with its original filename (prefixed with the Core Concept datetime-stamp, as usual).

### Sync

If the email and password have been set: once per minute, the app should sync the local files (anga, meta, and cache) with the Kaya Server over HTTP as per [@adr-0002-service-sync.md](./doc/arch/adr-0002-service-sync.md). You can follow the example found in [@sync.rb](./bin/sync.rb), but it is intended for a desktop operating system --- instead of `~/.kaya/`, the mobile apps will use the directory returned from `getApplicationSupportDirectory()` + `"/kaya"` as their root.

If the sync does not require any uploads or downloads, it is not logged (to avoid flooding logs with one message every minute). Any time data is sync'd up or down, or if the sync fails for some reason, that is logged. If the sync fails, notify the user with the orange "alert" icon mentioned in "UI: Header".

# Prompts

## First Pass: AGENTS + PLAN

While running `gradleDebug`, the process got stuck for a while and then the Claude Code process was killed by SIGKILL, somehow. This is a new thread. Please pick up where you left off. You don't need to build and test on physical devices if running on emulators is easier. Here is the previous prompt:

Read [@AGENTS.md](file:///Users/steven/work/deobald/kaya-flutter/AGENTS.md) and [@PLAN.md](file:///Users/steven/work/deobald/kaya-flutter/PLAN.md) , then implement the Kaya Flutter app according to the plan. Be sure to use Flutter from mise so it's up to date (3.38.5). There is a Samsung Galaxy A12 and an iPhone 11 SE attached by USB-C to this computer, if you want to do a native build to a real device.

## Change color scheme to GNOME guidelines

Follow the [GNOME Brand Guidelines](https://brand.gnome.org/) for the application's color scheme, though not for fonts.

Bug: The primary buttons are now hard to see. "Save", "Test Connection", and "Force Sync" do not contrast with the background.

## Tiles should always preview contents, when possible

Tiles for images (SVG, PNG, and so on) should render the image on the surface of the tile, in addition to rendering it on the Preview screen. Tiles for notes and quotes (`.md`) should render the text of the note on the surface of the tile, in addition to rendering the text on the Preview screen.

## Some Markdown tiles don't render inline

There is one markdown file that isn't rendering inline. It's a `-quote.md` file in the development environment with the name `2026-01-31T072529-quote.md`. A screenshot of it can be seen at [~/Downloads/markdown-rendering-incorrectly.jpeg](~/Downloads/markdown-rendering-incorrectly.jpeg)

This markdown file is a bit large. If that's the reason it isn't being rendered directly, a clip from the beginning of the file should be rendered with an ellipsis ("...") to indicate that not the entire file is shown on the tile.

## Connection Error when server offline

The Error/Warnings alert in the header is showing a lot of "sync failed" errors because the server is not running. When the periodic sync encounters a connection error, instead of stacking up a lot of errors to the Error/Warning alert, let's use a passive notification.

Add a "cloud" icon that's always visible immediately to the left of the "plus" icon (but to the right of the alert icon, if it's visible). When connections are successful, use the Material "Cloud Done" icon. When connections are failing due to a network error or the server being unreachable, use the Material "Cloud Off" icon. I don't believe there is an equivalent Cupertino Icon (a cloud AND a cloud with a line through it), but if there is, please use it.

---

The cloud icons are showing up, but when the app can't reach the service, it's still getting "Anga sync failed: ClientException with SocketException: Operation timed out (OS Error: Operation timed out, errno = 60)", and the same for Meta sync and Cache sync. This failure should not be an error, since the server is unreachable. This should also result in a "Cloud Off" icon. It should add errors to the log but should not display the error alert.

## Warning on `flutter run`

There is a red "Target native_assets required define SdkRoot but it was not provided" warning when using `flutter run`:

```
% flutter run -d 00008030-000C64291E3B802E
Launching lib/main.dart on Steven’s iPhone in debug mode...
Automatically signing iOS for device deployment using specified development team in Xcode project: Z8C46829M8
Running Xcode build...
Xcode build done.                                           20.7s
You may be prompted to give access to control Xcode. Flutter uses Xcode to run your app. If access is not allowed, you can change this through
your Settings > Privacy & Security > Automation.
Installing and launching...                                        24.5s
Target native_assets required define SdkRoot but it was not provided
Syncing files to device Steven’s iPhone...                          95ms

Flutter run key commands.
r Hot reload. 🔥🔥🔥
R Hot restart.
h List all available interactive commands.
d Detach (terminate "flutter run" but leave application running).
c Clear the screen
q Quit (terminate the application on the device).

A Dart VM Service on Steven’s iPhone is available at: http://127.0.0.1:52485/91r4qpeNe5w=/
The Flutter DevTools debugger and profiler on Steven’s iPhone is available at:
http://127.0.0.1:52485/91r4qpeNe5w=/devtools/?uri=ws://127.0.0.1:52485/91r4qpeNe5w=/ws
```

## Search via 'words' instead of 'cache'

Currently, the app downloads searchable content using the entire server-side cache from the Kaya Server. However, downloading the entire cache is very network-intensive.

Instead of downloading the entire cache, only download bookmark favicons to the local cache for displaying on tiles.

Where all the previous cache download behaviour was happening, download 'words' instead, as per [@adr-0002-service-sync.md](file:///Users/steven/work/deobald/kaya-flutter/doc/arch/adr-0002-service-sync.md).

Read [@PLAN.md](file:///Users/steven/work/deobald/kaya-flutter/doc/plan/PLAN.md) before planning and implementing.

### Don't hit the API unless a cached favicon or searchable 'words' text is missing

When the app syncs, it appears to request all the cached file indexes and 'words' indexes every time. This shouldn't be necessary. If the local app has a copy of a 'words' searchable text or if it already has a favicon for a given bookmark, it need not query the index again. If there was no favicon available, the local app should create a note to itself in the local cache by creating a `.nofavicon` turd file, which it can check for next time it syncs. If there is a `.nofavicon` turd file present, it shouldn't re-index that bookmark's API endpoint looking for one.

## BUG: "Save Metadata" is never enabled

Read [@PLAN.md](file:///Users/steven/work/deobald/kaya-flutter/doc/plan/PLAN.md) before planning and implementing.

When tags and/or notes are entered into an anga's PreviewScreen, doing so should enable the "Save Metadata" button. Clicking that button should save whichever tags and/or notes are present to a new meta file according to [@adr-0003-metadata.md](file:///Users/steven/work/deobald/kaya-flutter/doc/arch/adr-0003-metadata.md).

### Screen Flashing

Although the fix to the above bug works, now when typing in the "Tags" or "Notes" field, the entire screen flashes. The widgets above (ex. "Visit Original Page" button) become very briefly visible as the active widget moves down the screen. This could either be because the "Save Metadata" button is disappearing momentarily or some other rendering bug.

### Text Removal

When the "Save Metadata" button is clicked, the text entered in the "Tags" and/or "Notes" fields should not disappear. The user should continue to see what they will see if they click the Back button and return to this (active) preview, which is the text they just entered and saved.

## BUG: Sharing a URL should share the contents, not the `.url` file

Bookmarks and Notes are special (and first-class) in Kaya. Currently, notes are shared correctly, as the contents of the note. However, bookmarks are shared as a `.url` file, which most users will not expect/understand. Instead, when a URL is shared from Kaya to another application, it should be the URL text itself which is shared, not the `.url` file. Most receiving applications will understand how to interpret this and provide the user with a social preview, and so on.

## BUG: Cupertino Icons not used correctly

On iOS, the user should see familiar iOS-native icons whenever possible. Specifically, these icons should use their `cupertino_icons` counterparts on iOS:

* "Share" => "Share" (`share_up`) 
* "Download" => `cloud_download` 
* "Add" => `add_circled_solid`
* "Search" => `search` (specifically from `cupertino_icons`, as it is slightly different)
* "Bookmark" => `bookmark_fill` (again, slightly different)
* "PDF" => `doc_richtext`
* "Everything" => `home`
* "Account" => `profile_circled`
* "Test Connection" => `arrow_2_circlepath_circle_fill`

### Refactor to KayaIcon

Extract the platform-specific icon behaviour into `lib/core/widgets/kaya_icon.dart` to remove the duplication of testing `Platform.isIOS` in multiple places. Ensure every icon across the application is rendered via `KayaIcon`, even if there is not an iOS-specific icon from `cupertino_icons` available. There should be no calls to `Icons` from anywhere except `KayaIcon`, and that class should have a comment declaring as much.

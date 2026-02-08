# Share Extension Logging Plan

**Status:** Backed out (2026-02-07). To be reintroduced when `share_handler` text sharing is fixed or a custom ShareViewController is warranted.

## Context

The iOS Share Extension runs as a separate process from the main app. Its logs are not visible in Flutter's stdout/stderr, nor in the main app's log file. The only way to see them natively is via Console.app (filter for `ShareExtension`), which requires a Mac tethered to the device — impractical for production debugging.

We built a logging system that writes Share Extension logs to a file in the App Group shared container (`group.org.savebutton.app`), then reads them from the Dart side to display in the Troubleshooting screen. It was backed out because:

1. `ShareHandlerIosViewController` marks `viewDidLoad`/`viewDidAppear` as `public` (not `open`), so they cannot be overridden from outside the module. This prevented us from adding logging calls or fixing the `viewDidAppear` race condition.
2. Writing a fully custom `ShareViewController` (not subclassing `ShareHandlerIosViewController`) was deemed too much monkeypatching at this stage.

## Requirements When Reintroduced

- Share Extension logs must be stored and displayed **separately** from regular application logs (not appended under one combined view).
- Share Extension logging must be **disabled by default**.
- The user should have an option (toggle) in the Troubleshooting screen to **enable Share Extension logging** to diagnose sharing issues.
- When enabled, logs should be visible in the Troubleshooting screen and included in "Send To Developer" emails.

## Implementation That Was Backed Out

### 1. Swift: `ios/Share Extension/ShareExtensionLogger.swift`

Singleton logger writing to `share_extension.log` in the App Group container. Also logs via `NSLog` for Console.app.

```swift
import Foundation

class ShareExtensionLogger {
    static let shared = ShareExtensionLogger()

    private let logFileName = "share_extension.log"
    private let maxLogSize = 512 * 1024 // 512 KB
    private var logFileURL: URL?

    private init() {}

    func configure(appGroupId: String) {
        guard let containerURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupId
        ) else {
            NSLog("[ShareExtension] ERROR: Cannot access App Group container: \(appGroupId)")
            return
        }
        logFileURL = containerURL.appendingPathComponent(logFileName)
    }

    func log(_ message: String, level: String = "INFO") {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        let line = "[\(timestamp)] [\(level)] [ShareExtension] \(message)\n"
        NSLog("[ShareExtension] \(message)")
        guard let url = logFileURL else { return }
        do {
            if FileManager.default.fileExists(atPath: url.path) {
                let attrs = try FileManager.default.attributesOfItem(atPath: url.path)
                if let size = attrs[.size] as? Int, size > maxLogSize {
                    try "".write(to: url, atomically: true, encoding: .utf8)
                }
                let handle = try FileHandle(forWritingTo: url)
                handle.seekToEndOfFile()
                handle.write(line.data(using: .utf8)!)
                handle.closeFile()
            } else {
                try line.write(to: url, atomically: true, encoding: .utf8)
            }
        } catch {
            NSLog("[ShareExtension] ERROR writing log: \(error)")
        }
    }

    func info(_ message: String) { log(message, level: "INFO") }
    func warn(_ message: String) { log(message, level: "WARN") }
    func error(_ message: String) { log(message, level: "ERROR") }
}
```

### 2. Swift: `ShareViewController.swift` logging calls

The ShareViewController needs to call `ShareExtensionLogger.shared.configure(appGroupId:)` in `viewDidLoad` and add `log.info(...)` calls at each lifecycle stage. This requires either:
- Overriding methods on `ShareHandlerIosViewController` (blocked: methods are `public`, not `open`)
- Writing a custom `ShareViewController` that doesn't subclass it

### 3. Xcode project: Add `ShareExtensionLogger.swift` to Share Extension target

The file must be added to `project.pbxproj` in three places:
- `PBXBuildFile` section (build file entry)
- `PBXFileReference` section (file reference)
- `PBXGroup` for `Share Extension` (group children)
- `PBXSourcesBuildPhase` for the Share Extension target (sources list)

### 4. Dart: Read logs via `app_group_directory` package

```yaml
# pubspec.yaml
app_group_directory: ^2.0.0
```

In `LoggerService`, use `AppGroupDirectory.getAppGroupDirectory('group.org.savebutton.app')` to locate the shared container directory and read `share_extension.log`.

### 5. Dart: Display in Troubleshooting screen

Show Share Extension logs in a separate section/tab, only when the user has enabled Share Extension logging. Include the log file as a second attachment in "Send To Developer".

## Key Technical Notes

- App Group ID: `group.org.savebutton.app`
- Log file name: `share_extension.log`
- The Share Extension reads the App Group ID from `Info.plist` key `AppGroupId`, which is set via `$(CUSTOM_GROUP_ID)` build setting.
- `share_handler_ios_models` pod provides `SharedMedia`, `SharedAttachment`, `SharedAttachmentType` — these have zero Flutter dependency and are safe for the Share Extension target.
- `ShareHandlerIosViewController` has a race condition: `viewDidAppear` calls `extensionContext!.completeRequest()` before the async `handleInputItems()` Task launched in `viewDidLoad` finishes. This causes text sharing to fail (white screen, dismiss to home). URLs and images work because they're processed fast enough.

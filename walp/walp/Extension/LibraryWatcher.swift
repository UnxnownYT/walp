import Foundation

/// Extension-side half of the Phosphene-style contract.
///
/// Lives inside the Wallpaper extension target. Watches the shared library
/// folder that the main (non-sandboxed) walp app writes into, and reloads when
/// the app posts the `com.walp.libraryChanged` Darwin notification.
///
/// This does NOT touch WallpaperExtensionKit — keep Phosphene's provider/renderer
/// for that part. LibraryWatcher just answers "what videos exist, and which changed".
final class LibraryWatcher {

    static let shared = LibraryWatcher()

    private let libraryChangedNotification = "com.walp.libraryChanged" as CFString

    /// The extension is sandboxed, so its own container Documents folder IS the
    /// shared library path the app writes into.
    var libraryDirectory: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: docs, withIntermediateDirectories: true)
        return docs
    }

    /// All video files currently in the library.
    var videos: [URL] {
        let exts = ["mp4", "mov", "m4v"]
        let files = (try? FileManager.default.contentsOfDirectory(
            at: libraryDirectory,
            includingPropertiesForKeys: nil)) ?? []
        return files.filter { exts.contains($0.pathExtension.lowercased()) }
    }

    private var onChange: (() -> Void)?

    /// Start listening for library changes. `handler` runs whenever the app
    /// adds/updates a video.
    func start(onChange handler: @escaping () -> Void) {
        self.onChange = handler
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterAddObserver(
            center, observer,
            { _, observer, _, _, _ in
                guard let observer else { return }
                let watcher = Unmanaged<LibraryWatcher>.fromOpaque(observer).takeUnretainedValue()
                watcher.onChange?()
            },
            libraryChangedNotification, nil, .deliverImmediately)
    }

    func stop() {
        let center = CFNotificationCenterGetDarwinNotifyCenter()
        let observer = Unmanaged.passUnretained(self).toOpaque()
        CFNotificationCenterRemoveEveryObserver(center, observer)
    }
}

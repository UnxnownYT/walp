import Foundation

/// App-side half of the Phosphene-style contract.
///
/// The wallpaper *extension* is sandboxed and reads its video library from its own
/// container's Documents folder. This (non-sandboxed) app writes the chosen video
/// into that folder and pings the extension via a Darwin notification so it reloads.
///
/// IMPORTANT: set `extensionBundleID` to the bundle identifier you give the
/// Wallpaper extension target when you create it in Drop 2 (e.g. "com.walp.extension").
/// The extension must read from the same folder and listen for the same notification.
enum WallpaperInstaller {

    static let extensionBundleID = "com.walp.extension"
    static let libraryChangedNotification = "com.walp.libraryChanged"

    /// `~/Library/Containers/<extensionBundleID>/Data/Documents`
    static var libraryDirectory: URL? {
        guard let home = NSHomeDirectory() as String? else { return nil }
        let url = URL(fileURLWithPath: home)
            .appendingPathComponent("Library/Containers/\(extensionBundleID)/Data/Documents", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// Copies a local video file into the extension's library and notifies it.
    /// Returns the destination URL on success.
    @discardableResult
    static func install(videoAt source: URL, as fileName: String) throws -> URL {
        guard let dir = libraryDirectory else {
            throw NSError(domain: "walp", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "No library directory"])
        }
        let destination = dir.appendingPathComponent(fileName)
        if FileManager.default.fileExists(atPath: destination.path) {
            try FileManager.default.removeItem(at: destination)
        }
        try FileManager.default.copyItem(at: source, to: destination)
        postChange()
        return destination
    }

    /// Fire-and-forget Darwin notification the extension subscribes to.
    static func postChange() {
        let name = CFNotificationName(libraryChangedNotification as CFString)
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(), name, nil, nil, true)
    }
}

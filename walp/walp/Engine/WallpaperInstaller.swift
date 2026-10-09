import AppKit
import AVFoundation
import Foundation

/// App-side half of the lock-screen engine.
///
/// Hands videos to the walp wallpaper extension (adapted from Phosphene, MIT,
/// © kageroumado) using the same on-disk contract as Phosphene's
/// VideoDeploymentService:
///
///   ~/Library/Containers/<extensionBundleID>/Data/Documents/videos/<UUID>/
///       <video file>
///       metadata.json      (must match the extension's VideoEntry Codable shape)
///       thumbnail.jpg
///
/// then posts a Darwin notification so a running extension rescans its library.
///
/// Both constants below must match the extension. If you renamed Phosphene's
/// "glass.kagerou.phosphene" to "com.walp" everywhere, these are already right.
enum WallpaperInstaller {

    static let extensionBundleID = "com.walp.extension"
    static let libraryChangedNotification = "com.walp.libraryChanged"

    /// Mirrors the extension's VideoEntry. `variants` is left out; the extension
    /// decodes a missing key as nil.
    private struct Metadata: Codable {
        let id: String
        var name: String
        var filename: String
        var duration: Double
        var fps: Double
        var resolution: CGSize
        var dateAdded: Date
    }

    static var videosFolderURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Containers/\(extensionBundleID)/Data/Documents/videos")
    }

    /// Copy a video into the extension's library. Skips it if a video with the
    /// same filename is already there.
    static func deploy(url: URL, name: String) async {
        let fm = FileManager.default
        let videosDir = videosFolderURL
        try? fm.createDirectory(at: videosDir, withIntermediateDirectories: true)

        if existingFilenames().contains(url.lastPathComponent) {
            print("walp: '\(url.lastPathComponent)' already deployed, skipping")
            return
        }

        let id = UUID().uuidString
        let dir = videosDir.appendingPathComponent(id)

        do {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
            let destURL = dir.appendingPathComponent(url.lastPathComponent)
            try fm.copyItem(at: url, to: destURL)

            var fps: Double = 0
            var resolution: CGSize = .zero
            var duration: Double = 0
            let asset = AVURLAsset(url: destURL)
            if let track = try? await asset.loadTracks(withMediaType: .video).first {
                fps = Double((try? await track.load(.nominalFrameRate)) ?? 0)
                resolution = (try? await track.load(.naturalSize)) ?? .zero
                if let cmDuration = try? await asset.load(.duration) {
                    duration = CMTimeGetSeconds(cmDuration)
                }
            }

            let metadata = Metadata(id: id, name: name, filename: url.lastPathComponent,
                                    duration: duration, fps: fps, resolution: resolution,
                                    dateAdded: Date())
            try JSONEncoder().encode(metadata).write(to: dir.appendingPathComponent("metadata.json"))

            await writeThumbnail(for: destURL, in: dir)
            notifyExtension()
            print("walp: deployed '\(name)' as \(id)")
        } catch {
            print("walp: deploy failed — \(error.localizedDescription)")
            try? fm.removeItem(at: dir)
        }
    }

    /// Convert to HEVC first (what Wallper does for lock-screen compatibility),
    /// falling back to the original file if conversion fails.
    static func convertAndDeploy(url: URL, name: String) async {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("\((url.lastPathComponent as NSString).deletingPathExtension).mov")
        try? FileManager.default.removeItem(at: tempURL)

        guard let session = AVAssetExportSession(asset: AVURLAsset(url: url),
                                                 presetName: AVAssetExportPresetHEVCHighestQuality) else {
            await deploy(url: url, name: name)
            return
        }
        do {
            try await session.export(to: tempURL, as: .mov)
            await deploy(url: tempURL, name: name)
            try? FileManager.default.removeItem(at: tempURL)
        } catch {
            print("walp: HEVC conversion failed, deploying original — \(error.localizedDescription)")
            await deploy(url: url, name: name)
        }
    }

    // MARK: - Private

    private static func existingFilenames() -> Set<String> {
        let fm = FileManager.default
        guard let dirs = try? fm.contentsOfDirectory(at: videosFolderURL, includingPropertiesForKeys: nil,
                                                     options: .skipsHiddenFiles) else { return [] }
        var names = Set<String>()
        for dir in dirs where dir.hasDirectoryPath {
            guard let data = try? Data(contentsOf: dir.appendingPathComponent("metadata.json")),
                  let entry = try? JSONDecoder().decode(Metadata.self, from: data) else { continue }
            names.insert(entry.filename)
        }
        return names
    }

    private static func writeThumbnail(for videoURL: URL, in directory: URL) async {
        let generator = AVAssetImageGenerator(asset: AVURLAsset(url: videoURL))
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 640, height: 360)
        guard let cgImage = try? await generator.image(at: .zero).image,
              let jpeg = NSBitmapImageRep(cgImage: cgImage)
                  .representation(using: .jpeg, properties: [.compressionFactor: 0.85]) else { return }
        try? jpeg.write(to: directory.appendingPathComponent("thumbnail.jpg"), options: .atomic)
    }

    /// Clears WallpaperAgent's cached tiles (so System Settings sees the change
    /// even if the extension isn't running), then pings a live extension.
    private static func notifyExtension() {
        var buf = [CChar](repeating: 0, count: Int(PATH_MAX))
        let length = confstr(_CS_DARWIN_USER_CACHE_DIR, &buf, buf.count)
        if length > 0 {
            let cacheDir = URL(fileURLWithPath: String(cString: buf))
                .appendingPathComponent("com.apple.wallpaper.agent/com.apple.wallpaper.view-model-cache")
            for surface in ["desktop", "screenSaver"] {
                try? FileManager.default.removeItem(
                    at: cacheDir.appendingPathComponent("extension-\(extensionBundleID)-\(surface)"))
            }
        }
        CFNotificationCenterPostNotification(
            CFNotificationCenterGetDarwinNotifyCenter(),
            CFNotificationName(libraryChangedNotification as CFString), nil, nil, true)
    }
}

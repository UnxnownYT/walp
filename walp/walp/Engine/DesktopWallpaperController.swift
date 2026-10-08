import AppKit
import AVFoundation

/// Muro-style desktop wallpaper engine.
///
/// Draws one borderless window per screen, sitting just below the desktop icons,
/// playing a looping muted video. Fully controlled from the app — no extension,
/// no System Settings, no private frameworks.
///
/// Trade-off vs the Phosphene/WallpaperExtensionKit route: this draws on the
/// DESKTOP only, not the real lock screen (a window can't enter the secure
/// lock-screen context). Lock-screen video still needs the extension.
///
/// This is our own implementation of a well-known AppKit technique — not Muro's
/// code (Muro is PolyForm Shield licensed and can't be copied).
final class DesktopWallpaperController {

    static let shared = DesktopWallpaperController()

    private var windows: [WallpaperWindow] = []
    private var currentURL: URL?

    private init() {
        NotificationCenter.default.addObserver(
            self, selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }

    /// Start playing `url` as the wallpaper on every screen.
    func play(_ url: URL) {
        currentURL = url
        rebuildWindows()
    }

    /// Remove the wallpaper windows and go back to the system desktop.
    func stop() {
        currentURL = nil
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
    }

    @objc private func screensChanged() { rebuildWindows() }

    private func rebuildWindows() {
        windows.forEach { $0.orderOut(nil) }
        windows.removeAll()
        guard let url = currentURL else { return }
        for screen in NSScreen.screens {
            let window = WallpaperWindow(screen: screen, url: url)
            window.orderFrontRegardless()
            windows.append(window)
        }
    }
}

/// A borderless, click-through window pinned to one screen at desktop level.
private final class WallpaperWindow: NSWindow {
    private let player: AVQueuePlayer
    private let looper: AVPlayerLooper
    private let playerLayer: AVPlayerLayer

    init(screen: NSScreen, url: URL) {
        player = AVQueuePlayer()
        looper = AVPlayerLooper(player: player, templateItem: AVPlayerItem(url: url))
        playerLayer = AVPlayerLayer(player: player)

        super.init(contentRect: screen.frame,
                   styleMask: .borderless,
                   backing: .buffered,
                   defer: false)

        isOpaque = true
        backgroundColor = .black
        hasShadow = false
        ignoresMouseEvents = true                       // clicks pass through to the desktop
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle]
        // Sit below the desktop icons but above the static desktop picture.
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        setFrame(screen.frame, display: true)

        let host = NSView(frame: CGRect(origin: .zero, size: screen.frame.size))
        host.wantsLayer = true
        host.layer = CALayer()
        playerLayer.frame = host.bounds
        playerLayer.videoGravity = .resizeAspectFill
        playerLayer.autoresizingMask = [.layerWidthSizable, .layerHeightSizable]
        host.layer?.addSublayer(playerLayer)
        contentView = host

        player.isMuted = true                            // wallpapers stay silent
        player.play()
    }
}

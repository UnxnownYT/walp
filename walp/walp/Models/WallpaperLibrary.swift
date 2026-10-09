import SwiftUI
import Combine

final class WallpaperLibrary: ObservableObject {
    @Published var wallpapers: [Wallpaper] = Wallpaper.samples
    @Published var selectedCategory: Wallpaper.Category = .all
    @Published var current: Wallpaper?

    var filtered: [Wallpaper] {
        selectedCategory == .all ? wallpapers
            : wallpapers.filter { $0.category == selectedCategory }
    }
    var featured: Wallpaper? { wallpapers.first }

    private let lastKey = "walp.lastWallpaperTitle"

    func apply(_ wallpaper: Wallpaper) {
        current = wallpaper
        UserDefaults.standard.set(wallpaper.title, forKey: lastKey)
        // Desktop: play in-app. Lock screen: hand the same video to the extension.
        if let url = wallpaper.bundledURL {
            DesktopWallpaperController.shared.play(url)
            let name = wallpaper.title
            Task { await WallpaperInstaller.deploy(url: url, name: name) }
        }
    }

    /// Stop the live wallpaper and return to the system desktop.
    func clear() {
        current = nil
        UserDefaults.standard.removeObject(forKey: lastKey)
        DesktopWallpaperController.shared.stop()
    }

    /// Reapply the last-used wallpaper on launch.
    func restoreLast() {
        guard current == nil,
              let title = UserDefaults.standard.string(forKey: lastKey),
              let wallpaper = wallpapers.first(where: { $0.title == title }) else { return }
        apply(wallpaper)
    }
}

extension Wallpaper {
    static let samples: [Wallpaper] = [
        // Abstract — bundled in the app, Public Domain (VJ MoRpH / Internet Archive).
        // Download these 4 and name them exactly as the bundledResource below.
        .init(title: "Rainbow Swirl", category: .abstract, author: "VJ MoRpH", colors: [.pink, .purple],
              bundledResource: "DaftRainbowSwirlAVS1_512kb.mp4"),
        .init(title: "Flow Stripes",  category: .abstract, author: "VJ MoRpH", colors: [.orange, .pink],
              bundledResource: "FlowStripes01_1_512kb.mp4"),
        .init(title: "Dot Tunnel",    category: .abstract, author: "VJ MoRpH", colors: [.cyan, .blue],
              bundledResource: "RGBsoftDots3dtunnelMove01_1_640_512kb.mp4"),
        .init(title: "Star Clone",    category: .abstract, author: "VJ MoRpH", colors: [.indigo, .purple],
              bundledResource: "StarWithColourClone02_640_512kb.mp4"),

        // Space — NASA SVS (Public Domain). Large files, so download-on-demand later
        // via remoteURL (not yet wired; these show but won't apply until Drop 3).
        .init(title: "Earth: Kamchatka", category: .space, author: "NASA SVS", colors: [.black, .blue],
              remoteURL: URL(string: "https://svs.gsfc.nasa.gov/vis/a010000/a010700/a010766/Earth_View_Ocean_and_Land_limb.mov")),
        .init(title: "Earth: Australia", category: .space, author: "NASA SVS", colors: [.blue, .teal],
              remoteURL: URL(string: "https://svs.gsfc.nasa.gov/vis/a010000/a010700/a010766/Earth_View_Coast2.mov")),

        // Gradient-only placeholders — drop your own 2 clips in here as bundledResource.
        .init(title: "City Lights", category: .city,     author: "you", colors: [.purple, .black]),
        .init(title: "Minimal",     category: .abstract, author: "you", colors: [.gray, .cyan]),
    ]
}

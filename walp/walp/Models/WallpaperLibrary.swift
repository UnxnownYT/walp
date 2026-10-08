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

    func apply(_ wallpaper: Wallpaper) {
        current = wallpaper
        // Muro-style: play the video directly on the desktop, in-app.
        if let url = wallpaper.bundledURL {
            DesktopWallpaperController.shared.play(url)
        }
    }

    /// Stop the live wallpaper and return to the system desktop.
    func clear() {
        current = nil
        DesktopWallpaperController.shared.stop()
    }
}

extension Wallpaper {
    static let samples: [Wallpaper] = [
        // Abstract — bundled in the app, Public Domain (VJ MoRpH / Internet Archive).
        // Download these 4 and name them exactly as the bundledResource below.
        .init(title: "Rainbow Swirl", category: .abstract, author: "VJ MoRpH", colors: [.pink, .purple],
              bundledResource: "rainbow-swirl.mp4"),
        .init(title: "Flow Stripes",  category: .abstract, author: "VJ MoRpH", colors: [.orange, .pink],
              bundledResource: "flow-stripes.mp4"),
        .init(title: "Dot Tunnel",    category: .abstract, author: "VJ MoRpH", colors: [.cyan, .blue],
              bundledResource: "dot-tunnel.mp4"),
        .init(title: "Star Clone",    category: .abstract, author: "VJ MoRpH", colors: [.indigo, .purple],
              bundledResource: "star-clone.mp4"),

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

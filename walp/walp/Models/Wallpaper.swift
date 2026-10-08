import SwiftUI

struct Wallpaper: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: Category
    let author: String
    let colors: [Color]          // gradient thumbnail / fallback

    // Drop 2: where the actual video comes from.
    // `bundledResource` = a file shipped inside the app bundle (e.g. "aurora.mp4").
    // `remoteURL`       = a video to download on first use (for a bigger catalog later).
    var bundledResource: String? = nil
    var remoteURL: URL? = nil

    enum Category: String, CaseIterable, Identifiable {
        case all = "All", nature = "Nature", abstract = "Abstract"
        case space = "Space", city = "City", anime = "Anime"
        var id: String { rawValue }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }

    /// Resolves to a local file URL for the video, if one is available in the bundle.
    var bundledURL: URL? {
        guard let bundledResource else { return nil }
        let name = (bundledResource as NSString).deletingPathExtension
        let ext  = (bundledResource as NSString).pathExtension
        return Bundle.main.url(forResource: name, withExtension: ext.isEmpty ? "mp4" : ext)
    }
}

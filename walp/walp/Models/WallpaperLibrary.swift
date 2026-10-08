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
        // TODO (Drop 2): hand this off to the Phosphene-style wallpaper extension.
    }
}

extension Wallpaper {
    static let samples: [Wallpaper] = [
        .init(title: "Aurora Drift",  category: .nature,   author: "walp", colors: [.teal, .indigo]),
        .init(title: "Neon Rain",     category: .city,     author: "walp", colors: [.purple, .pink]),
        .init(title: "Deep Field",    category: .space,    author: "walp", colors: [.black, .blue]),
        .init(title: "Liquid Chrome", category: .abstract, author: "walp", colors: [.gray, .cyan]),
        .init(title: "Forest Fog",    category: .nature,   author: "walp", colors: [.green, .mint]),
        .init(title: "Midnight City", category: .city,     author: "walp", colors: [.blue, .black]),
        .init(title: "Sakura Night",  category: .anime,    author: "walp", colors: [.pink, .purple]),
        .init(title: "Nebula",        category: .space,    author: "walp", colors: [.indigo, .purple]),
        .init(title: "Prism",         category: .abstract, author: "walp", colors: [.orange, .pink]),
    ]
}

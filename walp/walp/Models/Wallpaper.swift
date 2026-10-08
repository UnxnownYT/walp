import SwiftUI

struct Wallpaper: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let category: Category
    let author: String
    let colors: [Color]   // placeholder gradient until real video is wired in

    enum Category: String, CaseIterable, Identifiable {
        case all = "All", nature = "Nature", abstract = "Abstract"
        case space = "Space", city = "City", anime = "Anime"
        var id: String { rawValue }
    }

    var gradient: LinearGradient {
        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

import SwiftUI

struct BrowseView: View {
    @EnvironmentObject private var library: WallpaperLibrary
    private let columns = [GridItem(.adaptive(minimum: 240), spacing: 16)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if let featured = library.featured {
                    FeaturedBanner(wallpaper: featured) { library.apply(featured) }
                }
                categoryChips
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(library.filtered) { wallpaper in
                        WallpaperCard(wallpaper: wallpaper,
                                      isCurrent: library.current == wallpaper)
                            .onTapGesture { library.apply(wallpaper) }
                    }
                }
            }
            .padding(24)
        }
        .background(backdrop)
    }

    // Dark gradient so the Liquid Glass elements have something to refract.
    private var backdrop: some View {
        LinearGradient(colors: [Color(red: 0.05, green: 0.05, blue: 0.09),
                                Color(red: 0.02, green: 0.02, blue: 0.04)],
                       startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Wallpaper.Category.allCases) { chip(for: $0) }
            }
            .padding(.vertical, 2)
        }
    }

    @ViewBuilder
    private func chip(for category: Wallpaper.Category) -> some View {
        let selected = library.selectedCategory == category
        let label = Text(category.rawValue)
            .font(.subheadline.weight(.medium))
            .padding(.horizontal, 14).padding(.vertical, 7)
            .foregroundStyle(selected ? .white : .primary)

        Group {
            if selected {
                label.glassyTinted(.capsule, tint: .accentColor)
            } else {
                label.glassy(.capsule)
            }
        }
        .contentShape(Capsule())
        .onTapGesture { library.selectedCategory = category }
    }
}

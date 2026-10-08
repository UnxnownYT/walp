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
        .background(.black)
    }

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Wallpaper.Category.allCases) { category in
                    let selected = library.selectedCategory == category
                    Text(category.rawValue)
                        .font(.subheadline.weight(.medium))
                        .padding(.horizontal, 14).padding(.vertical, 7)
                        .background(selected ? AnyShapeStyle(.tint)
                                             : AnyShapeStyle(.regularMaterial), in: Capsule())
                        .foregroundStyle(selected ? .white : .primary)
                        .onTapGesture { library.selectedCategory = category }
                }
            }
        }
    }
}

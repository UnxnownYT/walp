import SwiftUI

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    let isCurrent: Bool
    @State private var hovering = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(wallpaper.gradient)
                .aspectRatio(16/10, contentMode: .fit)

            LinearGradient(colors: [.clear, .black.opacity(0.55)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(wallpaper.title).font(.headline)
                Text(wallpaper.author).font(.caption).foregroundStyle(.white.opacity(0.7))
            }
            .padding(12).foregroundStyle(.white)

            if isCurrent {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.white, .green).padding(10)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            }
        }
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(.white.opacity(hovering ? 0.4 : 0.08), lineWidth: 1))
        .scaleEffect(hovering ? 1.02 : 1)
        .shadow(color: .black.opacity(hovering ? 0.4 : 0), radius: 12, y: 6)
        .animation(.easeOut(duration: 0.18), value: hovering)
        .onHover { hovering = $0 }
    }
}

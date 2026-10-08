import SwiftUI

struct WallpaperCard: View {
    let wallpaper: Wallpaper
    let isCurrent: Bool
    @State private var hovering = false

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(wallpaper.gradient)
                .aspectRatio(16/10, contentMode: .fit)

            // Liquid Glass label strip floating over the thumbnail.
            HStack(spacing: 8) {
                VStack(alignment: .leading, spacing: 1) {
                    Text(wallpaper.title).font(.subheadline.weight(.semibold))
                    Text(wallpaper.author).font(.caption2).foregroundStyle(.secondary)
                }
                Spacer()
                if isCurrent {
                    Image(systemName: "play.circle.fill").foregroundStyle(.white)
                }
            }
            .padding(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassy(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(8)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(.white.opacity(hovering ? 0.5 : 0.08), lineWidth: 1)
        )
        .scaleEffect(hovering ? 1.02 : 1)
        .shadow(color: .black.opacity(hovering ? 0.45 : 0), radius: 14, y: 8)
        .animation(.easeOut(duration: 0.18), value: hovering)
        .onHover { hovering = $0 }
    }
}

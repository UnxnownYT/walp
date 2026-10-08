import SwiftUI

struct FeaturedBanner: View {
    let wallpaper: Wallpaper
    let onApply: () -> Void

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(wallpaper.gradient).frame(height: 260)

            LinearGradient(colors: [.clear, .black.opacity(0.6)],
                           startPoint: .center, endPoint: .bottom)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

            VStack(alignment: .leading, spacing: 10) {
                Text("Featured").font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.8))
                Text(wallpaper.title).font(.largeTitle.bold())
                Button(action: onApply) {
                    Label("Set as Wallpaper", systemImage: "play.fill").padding(.horizontal, 6)
                }
                .buttonStyle(.borderedProminent).controlSize(.large)
            }
            .padding(24).foregroundStyle(.white)
        }
    }
}

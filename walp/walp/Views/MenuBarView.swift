import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject private var library: WallpaperLibrary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("walp").font(.headline)
            if let current = library.current {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(current.gradient).frame(height: 90)
                    .overlay(alignment: .bottomLeading) {
                        Text(current.title).font(.caption.bold())
                            .foregroundStyle(.white).padding(8)
                    }
            } else {
                Text("No wallpaper set").foregroundStyle(.secondary)
            }
            Divider()
            Button("Open walp") { NSApp.activate(ignoringOtherApps: true) }
            Button("Quit") { NSApp.terminate(nil) }
        }
        .padding(14).frame(width: 260)
    }
}

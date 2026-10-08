import SwiftUI

@main
struct WalpApp: App {
    @StateObject private var library = WallpaperLibrary()

    var body: some Scene {
        WindowGroup {
            BrowseView()
                .environmentObject(library)
                .frame(minWidth: 900, minHeight: 600)
                .preferredColorScheme(.dark)
                .onAppear { library.restoreLast() }
        }
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra("walp", systemImage: "sparkles.tv") {
            MenuBarView().environmentObject(library)
        }
        .menuBarExtraStyle(.window)
    }
}

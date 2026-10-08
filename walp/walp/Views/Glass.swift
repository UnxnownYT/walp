import SwiftUI

/// Applies macOS 26 Liquid Glass where available, with a graceful material
/// fallback on older systems. Use on chips, panels, toolbars, and labels.
extension View {
    @ViewBuilder
    func glassy<S: Shape>(_ shape: S) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular, in: shape)
        } else {
            self.background(.ultraThinMaterial, in: shape)
        }
    }

    /// Interactive/tinted glass for selected states (e.g. the active category).
    @ViewBuilder
    func glassyTinted<S: Shape>(_ shape: S, tint: Color) -> some View {
        if #available(macOS 26.0, *) {
            self.glassEffect(.regular.tint(tint).interactive(), in: shape)
        } else {
            self.background(tint, in: shape)
        }
    }
}

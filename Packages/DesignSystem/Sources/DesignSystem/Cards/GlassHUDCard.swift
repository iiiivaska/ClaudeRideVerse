import SwiftUI

/// Rounded-20 glass card for floating HUDs (recording bar, compass readout).
/// Uses the tuned `.hud` glass recipe — stronger blur + inset border.
public struct GlassHUDCard<Content: View>: View {

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .padding(.horizontal, FogSpacing.m)
            .padding(.vertical, FogSpacing.s)
            .clipShape(.rect(cornerRadius: FogRadius.xxl, style: .continuous))
            .fogGlass(level: .hud)
    }
}

#Preview("GlassHUDCard") {
    GlassHUDCard {
        HStack(spacing: FogSpacing.l) {
            MonoVal("24.8", size: .xl)
            MonoVal("1:23", size: .xl, color: .fogAccent)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

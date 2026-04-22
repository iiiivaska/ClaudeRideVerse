import SwiftUI

/// Rounded-100 glass pill used for floating map info, stat strips, and compact
/// action containers. Padding 10×18 per prototype.
public struct GlassPill<Content: View>: View {

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: FogSpacing.xxs + 2) { // 6pt matches prototype gap
            content
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 18)
        .clipShape(.rect(cornerRadius: FogRadius.pill, style: .continuous))
        .fogGlass(level: .control)
    }
}

#Preview("GlassPill") {
    VStack(spacing: FogSpacing.m) {
        GlassPill {
            MonoVal("24.8", size: .md, color: .fogAccent)
            MonoLabel("km")
        }
        GlassPill {
            Image(systemName: "location.fill")
                .foregroundStyle(Color.fogAccent)
            MonoVal("GPS locked", size: .sm, color: .fogTextSecondary)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

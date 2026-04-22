import SwiftUI

/// Thin wrapper modifier that attaches `fogPulse(.hexGlow)` to any view.
/// Useful when `HexCell(.newUnlock)` is insufficient — e.g. on composed
/// illustrations or map overlays rendered outside `HexCell`.
public extension View {
    func fogHexGlow() -> some View {
        fogPulse(.hexGlow)
    }
}

/// Standalone example host (not shipped — used by Preview gallery).
public struct HexGlowPulseExample: View {
    public init() {}
    public var body: some View {
        HexPathGeneratorExampleShape()
            .fill(Color.fogAccent)
            .frame(width: 60, height: 60)
            .fogHexGlow()
    }
}

private struct HexPathGeneratorExampleShape: Shape {
    func path(in rect: CGRect) -> Path {
        HexPathGenerator.hexPath(
            center: CGPoint(x: rect.midX, y: rect.midY),
            radius: min(rect.width, rect.height) / 2
        )
    }
}

#Preview("HexGlowPulse") {
    HexGlowPulseExample()
        .padding(FogSpacing.xl)
        .background(Color.fogBg)
        .preferredColorScheme(.dark)
}

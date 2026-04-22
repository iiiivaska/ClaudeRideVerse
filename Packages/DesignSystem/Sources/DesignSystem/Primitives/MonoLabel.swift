import SwiftUI

/// Small caps-label primitive: IBM Plex Mono 9px, tracking 0.12em, uppercase, color `tq`.
/// Used across metrics grids, section headers, and card subtitles (8 of 10 screens).
public struct MonoLabel: View {

    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text.uppercased())
            .font(.fogMonoCap)
            .tracking(1.08) // 9px * 0.12em ≈ 1.08pt letter spacing
            .foregroundStyle(Color.fogTextQuaternary)
    }
}

#Preview("MonoLabel") {
    VStack(spacing: FogSpacing.s) {
        MonoLabel("Distance")
        MonoLabel("Hex")
        MonoLabel("Moving time")
    }
    .padding()
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

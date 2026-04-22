import SwiftUI

/// Destructive circular button — 60×60, accent red, inset white square glyph.
/// Used as the stop control in the Recording HUD.
public struct StopButton: View {

    public static var defaultSize: CGFloat { 60 }

    private let size: CGFloat
    private let action: @Sendable () -> Void

    public init(size: CGFloat = StopButton.defaultSize, action: @escaping @Sendable () -> Void) {
        self.size = size
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            ZStack {
                Circle().fill(Color.fogRed)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(Color.white)
                    .frame(width: size * 0.35, height: size * 0.35)
            }
            .frame(width: size, height: size)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text("Stop"))
    }
}

#Preview("StopButton") {
    HStack(spacing: FogSpacing.l) {
        StopButton { }
        StopButton(size: 80) { }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

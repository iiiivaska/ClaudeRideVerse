import SwiftUI

/// Map user-location marker — accent dot with concentric pulsing ring.
public struct LocationPulseRing: View {

    private let dotSize: CGFloat

    public init(dotSize: CGFloat = 16) {
        self.dotSize = dotSize
    }

    public var body: some View {
        ZStack {
            Circle()
                .fill(Color.fogAccent)
                .frame(width: dotSize, height: dotSize)
                .fogPulse(.accent)
            Circle()
                .fill(Color.fogAccent)
                .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
                .frame(width: dotSize, height: dotSize)
        }
        .accessibilityHidden(true)
    }
}

#Preview("LocationPulseRing") {
    LocationPulseRing()
        .frame(width: 80, height: 80)
        .padding()
        .background(Color.fogBg)
        .preferredColorScheme(.dark)
}

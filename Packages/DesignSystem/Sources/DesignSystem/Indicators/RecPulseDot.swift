import SwiftUI

/// Recording indicator — 7pt red dot with red box-shadow pulse.
public struct RecPulseDot: View {

    private let size: CGFloat

    public init(size: CGFloat = 7) {
        self.size = size
    }

    public var body: some View {
        Circle()
            .fill(Color.fogRed)
            .frame(width: size, height: size)
            .fogPulse(.red)
            .accessibilityHidden(true)
    }
}

#Preview("RecPulseDot") {
    HStack(spacing: FogSpacing.xs) {
        RecPulseDot()
        Text("REC")
            .font(.fogCaption)
            .foregroundStyle(Color.fogTextPrimary)
    }
    .padding()
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

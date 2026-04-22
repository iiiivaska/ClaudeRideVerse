import SwiftUI

/// Page-indicator dots for the onboarding flow. The active dot stretches
/// into an 18×6 pill; the rest stay circular (6×6) with `fogTextQuaternary`.
public struct OnboardingDots: View {

    private let total: Int
    private let activeIndex: Int

    public init(activeIndex: Int, total: Int) {
        precondition(total > 0, "OnboardingDots requires at least 1 page")
        precondition(activeIndex >= 0 && activeIndex < total, "activeIndex out of range")
        self.total = total
        self.activeIndex = activeIndex
    }

    public var body: some View {
        HStack(spacing: FogSpacing.xs) {
            ForEach(0..<total, id: \.self) { index in
                let isActive = index == activeIndex
                Capsule(style: .continuous)
                    .fill(isActive ? Color.fogAccent : Color.fogTextQuaternary)
                    .frame(width: isActive ? 18 : 6, height: 6)
                    .animation(.easeOut(duration: 0.22), value: activeIndex)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("Page \(activeIndex + 1) of \(total)"))
    }
}

#Preview("OnboardingDots") {
    VStack(spacing: FogSpacing.l) {
        OnboardingDots(activeIndex: 0, total: 4)
        OnboardingDots(activeIndex: 2, total: 4)
        OnboardingDots(activeIndex: 3, total: 4)
    }
    .padding()
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

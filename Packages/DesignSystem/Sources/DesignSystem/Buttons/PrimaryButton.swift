import SwiftUI

/// Primary call-to-action pill button. 56pt tall, accent-filled, with the
/// prototype's `0 4px 28px acc 0.44` glow shadow. Used for `Start Ride`,
/// `Get Premium`, and onboarding CTAs.
public struct FogPrimaryButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.fogButton)
            .foregroundStyle(Color.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Color.fogAccent,
                in: .rect(cornerRadius: FogRadius.pill, style: .continuous)
            )
            .fogShadow(FogShadow.accentGlow)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == FogPrimaryButtonStyle {
    static var fogPrimary: FogPrimaryButtonStyle { FogPrimaryButtonStyle() }
}

#Preview("PrimaryButton") {
    VStack(spacing: FogSpacing.m) {
        Button("Start Ride") { }
            .buttonStyle(.fogPrimary)
        Button("Get Premium") { }
            .buttonStyle(.fogPrimary)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

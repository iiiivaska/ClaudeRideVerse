import SwiftUI

/// Secondary pill button — surface-2 fill with subtle separator border.
/// No glow shadow. Used for "Allow later", "Dismiss", "Maybe later" CTAs.
public struct FogSecondaryButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.fogButton)
            .foregroundStyle(Color.fogTextPrimary)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                Color.fogSurface2,
                in: .rect(cornerRadius: FogRadius.pill, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FogRadius.pill, style: .continuous)
                    .strokeBorder(Color.fogSeparator, lineWidth: 1)
            )
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

public extension ButtonStyle where Self == FogSecondaryButtonStyle {
    static var fogSecondary: FogSecondaryButtonStyle { FogSecondaryButtonStyle() }
}

#Preview("SecondaryButton") {
    VStack(spacing: FogSpacing.m) {
        Button("Not now") { }
            .buttonStyle(.fogSecondary)
        Button("Maybe later") { }
            .buttonStyle(.fogSecondary)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

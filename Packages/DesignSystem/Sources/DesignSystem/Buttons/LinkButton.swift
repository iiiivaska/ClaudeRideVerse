import SwiftUI

/// Tertiary link-style button — transparent background, fogTextTertiary colour,
/// 13pt caption font. Used under onboarding CTAs ("I have an account", "Not now").
public struct FogLinkButtonStyle: ButtonStyle {

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.fogCaption)
            .foregroundStyle(Color.fogTextTertiary)
            .underline(configuration.isPressed)
            .padding(.vertical, FogSpacing.xs)
            .padding(.horizontal, FogSpacing.s)
            .contentShape(.rect)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
    }
}

public extension ButtonStyle where Self == FogLinkButtonStyle {
    static var fogLink: FogLinkButtonStyle { FogLinkButtonStyle() }
}

#Preview("LinkButton") {
    VStack(spacing: FogSpacing.s) {
        Button("I have an account") { }
            .buttonStyle(.fogLink)
        Button("Not now") { }
            .buttonStyle(.fogLink)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

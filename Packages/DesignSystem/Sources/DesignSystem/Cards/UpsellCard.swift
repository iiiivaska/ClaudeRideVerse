import SwiftUI

/// Premium upsell container. Linear gradient from `accent 18%` down to
/// `green 6%`, with a `accentBorder` stroke. Used on Profile and Paywall.
public struct UpsellCard<Content: View>: View {

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                LinearGradient(
                    stops: [
                        .init(color: .fogAccent.opacity(0.18), location: 0),
                        .init(color: .fogGreen.opacity(0.06), location: 1),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                in: .rect(cornerRadius: FogRadius.m, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FogRadius.m, style: .continuous)
                    .strokeBorder(Color.fogAccentBorder, lineWidth: 1)
            )
    }
}

#Preview("UpsellCard") {
    UpsellCard {
        VStack(alignment: .leading, spacing: FogSpacing.s) {
            MonoLabel("Premium")
            Text("Unlock offline maps and AI route suggestions")
                .font(.fogBody)
                .foregroundStyle(Color.fogTextPrimary)
            Button("Get Premium") { }
                .buttonStyle(.fogPrimary)
        }
        .padding(FogSpacing.m)
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

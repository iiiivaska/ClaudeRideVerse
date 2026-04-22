import SwiftUI

/// Settings / rides list container — `fogSurface1` fill, `fogSeparator` 1pt
/// border, 12pt radius. No glass. Content uses Dividers between rows.
public struct GroupedCard<Content: View>: View {

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .background(
                Color.fogSurface1,
                in: .rect(cornerRadius: FogRadius.m, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: FogRadius.m, style: .continuous)
                    .strokeBorder(Color.fogSeparator, lineWidth: 1)
            )
    }
}

#Preview("GroupedCard") {
    GroupedCard {
        VStack(spacing: 0) {
            settingsRow("Auto-pause", value: "On")
            Divider().overlay(Color.fogSeparator)
            settingsRow("Units", value: "Metric")
            Divider().overlay(Color.fogSeparator)
            settingsRow("Haptics", value: "On")
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

private func settingsRow(_ title: String, value: String) -> some View {
    HStack {
        Text(title)
            .font(.fogBody)
            .foregroundStyle(Color.fogTextPrimary)
        Spacer()
        Text(value)
            .font(.fogBody)
            .foregroundStyle(Color.fogTextTertiary)
    }
    .padding(.horizontal, FogSpacing.m)
    .padding(.vertical, FogSpacing.s)
}

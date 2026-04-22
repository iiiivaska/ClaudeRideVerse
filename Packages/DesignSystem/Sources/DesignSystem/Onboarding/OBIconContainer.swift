import SwiftUI

/// 88×88 rounded-24 icon container for onboarding permission prompts.
/// Soft accent or red background with a matching border and a centred glyph.
public struct OBIconContainer<Content: View>: View {

    public enum Tone: Sendable {
        case accent
        case red

        var fill: Color {
            switch self {
            case .accent: return .fogAccentSoft
            case .red: return .fogRed.opacity(0.15)
            }
        }

        var border: Color {
            switch self {
            case .accent: return .fogAccentBorder
            case .red: return .fogRed.opacity(0.35)
            }
        }
    }

    private let tone: Tone
    private let content: Content

    public init(tone: Tone = .accent, @ViewBuilder content: () -> Content) {
        self.tone = tone
        self.content = content()
    }

    public var body: some View {
        content
            .frame(width: 88, height: 88)
            .background(tone.fill, in: .rect(cornerRadius: FogRadius.xxxl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: FogRadius.xxxl, style: .continuous)
                    .strokeBorder(tone.border, lineWidth: 1)
            )
    }
}

#Preview("OBIconContainer") {
    HStack(spacing: FogSpacing.l) {
        OBIconContainer(tone: .accent) {
            Image(systemName: "location.fill")
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(Color.fogAccent)
        }
        OBIconContainer(tone: .red) {
            Image(systemName: "heart.fill")
                .font(.system(size: 36, weight: .regular))
                .foregroundStyle(Color.fogRed)
        }
    }
    .padding()
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

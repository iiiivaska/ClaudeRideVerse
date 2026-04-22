import SwiftUI

/// Monospaced metric value. IBM Plex Mono 20–24px, `line-height: 1`.
/// Used anywhere a number is rendered (HUD metrics, Trip Summary cells, Stats).
public struct MonoVal: View {

    public enum Size: Sendable {
        case xl  // 24pt — Trip Summary cell values
        case lg  // 20pt — HUD value (speed, hex, km)
        case md  // 14pt — ride item distance/duration, stat cards
        case sm  // 11pt — stat strip, ride sub

        var font: Font {
            switch self {
            case .xl: return .fogMonoXL
            case .lg: return .fogMonoLg
            case .md: return .fogMonoMd
            case .sm: return .fogMonoSm
            }
        }
    }

    private let text: String
    private let size: Size
    private let color: Color

    public init(_ text: String, size: Size = .lg, color: Color = .fogTextPrimary) {
        self.text = text
        self.size = size
        self.color = color
    }

    public var body: some View {
        Text(text)
            .font(size.font)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .foregroundStyle(color)
    }
}

#Preview("MonoVal") {
    VStack(alignment: .leading, spacing: FogSpacing.m) {
        MonoVal("24.8", size: .xl)
        MonoVal("342", size: .lg, color: .fogAccent)
        MonoVal("1:23", size: .md)
        MonoVal("18.3 km/h", size: .sm, color: .fogTextSecondary)
    }
    .padding()
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

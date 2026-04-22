import SwiftUI

/// Typography scale for FogRide. Backed by Apple's system typefaces:
/// - **SF Pro** for headings, body, buttons, navigation (`design: .default`)
/// - **SF Mono** for every numeric value, metric, caps-label, and tag
///   (`design: .monospaced`)
///
/// Sizes and weights mirror the React prototype (`Design/Prototype/FogRide
/// Prototype.html`). Sizes are fixed — this matches the prototype's ethos
/// where metric layouts must not reflow; for flexible body copy use
/// `.font(.body)` directly or attach Dynamic Type via `.dynamicTypeSize`.
public extension Font {

    // MARK: - SF Pro (sans)

    static var fogTitleL: Font { .system(size: 26, weight: .bold) }
    static var fogHeading: Font { .system(size: 22, weight: .bold) }
    static var fogButton: Font { .system(size: 16, weight: .semibold) }
    static var fogBody: Font { .system(size: 14, weight: .regular) }
    static var fogCaption: Font { .system(size: 13, weight: .medium) }
    static var fogMicro: Font { .system(size: 11, weight: .regular) }

    // MARK: - SF Mono (monospaced)

    static var fogMonoXL: Font { .system(size: 24, weight: .semibold, design: .monospaced) }
    static var fogMonoLg: Font { .system(size: 20, weight: .semibold, design: .monospaced) }
    static var fogMonoMd: Font { .system(size: 14, weight: .medium, design: .monospaced) }
    static var fogMonoSm: Font { .system(size: 11, weight: .medium, design: .monospaced) }
    static var fogMonoCap: Font { .system(size: 9, weight: .medium, design: .monospaced) }
}

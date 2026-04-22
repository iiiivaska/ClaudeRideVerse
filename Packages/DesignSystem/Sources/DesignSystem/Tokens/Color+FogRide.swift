import SwiftUI

public extension Color {

    // Surfaces
    static let fogBg = Color(fogHex: 0x000000)
    static let fogSurface1 = Color(fogHex: 0x1C1C1E)
    static let fogSurface2 = Color(fogHex: 0x2C2C2E)
    static let fogSurface3 = Color(fogHex: 0x3A3A3C)

    // Separators
    static let fogSeparator = Color(white: 1.0, alpha: 0.08)
    static let fogSeparatorStrong = Color(white: 1.0, alpha: 0.14)

    // Text
    static let fogTextPrimary = Color.white
    static let fogTextSecondary = Color(fogTextRGB: 235, alpha: 0.80)
    static let fogTextTertiary = Color(fogTextRGB: 235, alpha: 0.55)
    static let fogTextQuaternary = Color(fogTextRGB: 235, alpha: 0.28)

    // Accent
    static let fogAccent = Color(fogHex: 0x0A84FF)
    static let fogAccentSoft = Color(fogRGB: (10, 132, 255), alpha: 0.15)
    static let fogAccentBorder = Color(fogRGB: (10, 132, 255), alpha: 0.35)

    // Status
    static let fogGreen = Color(fogHex: 0x30D158)
    static let fogGreenSoft = Color(fogRGB: (48, 209, 88), alpha: 0.12)
    static let fogRed = Color(fogHex: 0xFF453A)
    static let fogOrange = Color(fogHex: 0xFF9F0A)
    static let fogYellow = Color(fogHex: 0xFFD60A)

    // Glass
    static let fogGlassBg = Color(fogRGB: (22, 22, 24), alpha: 0.86)
    static let fogGlassBgTabBar = Color(fogRGB: (20, 20, 22), alpha: 0.90)
    static let fogGlassBorder = Color(white: 1.0, alpha: 0.10)
    static let fogGlassBorderTabBar = Color(white: 1.0, alpha: 0.13)

    // Tab-bar inactive text
    static let fogTabInactive = Color(fogTextRGB: 235, alpha: 0.40)
}

// MARK: - Internal initializers

extension Color {

    init(fogHex rgb: UInt32) {
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1.0)
    }

    init(fogRGB rgb: (r: Int, g: Int, b: Int), alpha: Double) {
        self.init(
            .sRGB,
            red: Double(rgb.r) / 255.0,
            green: Double(rgb.g) / 255.0,
            blue: Double(rgb.b) / 255.0,
            opacity: alpha
        )
    }

    init(fogTextRGB value: Int, alpha: Double) {
        self.init(fogRGB: (value, value, 245), alpha: alpha)
    }

    init(white: Double, alpha: Double) {
        self.init(.sRGB, red: white, green: white, blue: white, opacity: alpha)
    }
}

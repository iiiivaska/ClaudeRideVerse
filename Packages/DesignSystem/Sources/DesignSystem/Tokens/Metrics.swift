import SwiftUI

public enum FogSpacing {
    public static let xxs: CGFloat = 4
    public static let xs: CGFloat = 8
    public static let s: CGFloat = 12
    public static let m: CGFloat = 16
    public static let l: CGFloat = 20
    public static let xl: CGFloat = 24
    public static let xxl: CGFloat = 32
}

public enum FogRadius {
    public static let xs: CGFloat = 8
    public static let s: CGFloat = 10
    public static let m: CGFloat = 12
    public static let l: CGFloat = 14
    public static let xl: CGFloat = 16
    public static let xxl: CGFloat = 20
    public static let xxxl: CGFloat = 24
    public static let device: CGFloat = 48
    public static let pill: CGFloat = 100
}

public enum FogShadow {

    public static let accentGlow = FogShadowStyle(
        color: .fogAccent.opacity(0.44),
        radius: 28,
        x: 0,
        y: 4
    )

    public static let tabBarPrimary = FogShadowStyle(
        color: .black.opacity(0.6),
        radius: 48,
        x: 0,
        y: 12
    )

    public static let tabBarSecondary = FogShadowStyle(
        color: .black.opacity(0.4),
        radius: 8,
        x: 0,
        y: 2
    )

    public static let hud = FogShadowStyle(
        color: .black.opacity(0.5),
        radius: 20,
        x: 0,
        y: 8
    )
}

public struct FogShadowStyle: Sendable, Equatable {
    public let color: Color
    public let radius: CGFloat
    public let x: CGFloat
    public let y: CGFloat

    public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
        self.color = color
        self.radius = radius
        self.x = x
        self.y = y
    }
}

public extension View {
    func fogShadow(_ style: FogShadowStyle) -> some View {
        shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }
}

import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Metric constants — values match design spec")
struct MetricsTests {

    @Test("Radii cover every corner-size used in Дизайн-система")
    func radiiValues() {
        #expect(FogRadius.xs == 8)
        #expect(FogRadius.s == 10)
        #expect(FogRadius.m == 12)
        #expect(FogRadius.l == 14)
        #expect(FogRadius.xl == 16)
        #expect(FogRadius.xxl == 20)
        #expect(FogRadius.xxxl == 24)
        #expect(FogRadius.device == 48)
        #expect(FogRadius.pill == 100)
    }

    @Test("Spacing tiers are monotonic")
    func spacingMonotonic() {
        let tiers = [
            FogSpacing.xxs, FogSpacing.xs, FogSpacing.s, FogSpacing.m,
            FogSpacing.l, FogSpacing.xl, FogSpacing.xxl,
        ]
        #expect(tiers == tiers.sorted())
    }

    @Test("Accent glow shadow — radius 28, y 4, alpha 0.44 per prototype")
    func accentGlowShadow() {
        let glow = FogShadow.accentGlow
        #expect(glow.radius == 28)
        #expect(glow.y == 4)
        #expect(glow.x == 0)
        let opacity = Double(glow.color.resolve(in: EnvironmentValues()).opacity)
        #expect(abs(opacity - 0.44) < 0.01)
    }

    @Test("Tab bar uses dual shadows with matching specs")
    func tabBarDualShadow() {
        #expect(FogShadow.tabBarPrimary.radius == 48)
        #expect(FogShadow.tabBarSecondary.radius == 8)
        #expect(FogShadow.tabBarPrimary.y == 12)
        #expect(FogShadow.tabBarSecondary.y == 2)
    }
}

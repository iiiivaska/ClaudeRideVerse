import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Color tokens — exact values from prototype const T")
struct ColorTokenTests {

    @Test("Hex initializer decodes RGB bytes")
    func hexInitDecodesBytes() {
        let components = resolve(Color(fogHex: 0x0A84FF))
        #expect(approx(Double(components.red), 10.0 / 255.0))
        #expect(approx(Double(components.green), 132.0 / 255.0))
        #expect(approx(Double(components.blue), 255.0 / 255.0))
        #expect(approx(Double(components.opacity), 1.0))
    }

    @Test("RGBA initializer preserves alpha at tertiary tier 0.55")
    func rgbaPreservesAlpha() {
        let components = resolve(Color(fogRGB: (235, 235, 245), alpha: 0.55))
        #expect(approx(Double(components.opacity), 0.55))
    }

    @Test("Separator alpha boundary — 0.08")
    func separatorAlphaBoundary() {
        let components = resolve(Color.fogSeparator)
        #expect(approx(Double(components.opacity), 0.08))
    }

    @Test("Glass bg alpha — 0.86 for HUD, 0.90 for tab bar")
    func glassAlphaTiers() {
        let hud = resolve(Color.fogGlassBg)
        let tabBar = resolve(Color.fogGlassBgTabBar)
        #expect(approx(Double(hud.opacity), 0.86))
        #expect(approx(Double(tabBar.opacity), 0.90))
    }

    @Test("Text tier alphas match const T")
    func textTierAlphas() {
        let tiers: [(Color, Double)] = [
            (.fogTextSecondary, 0.80),
            (.fogTextTertiary, 0.55),
            (.fogTextQuaternary, 0.28),
            (.fogTabInactive, 0.40),
        ]
        for (color, expected) in tiers {
            let opacity = Double(resolve(color).opacity)
            #expect(approx(opacity, expected))
        }
    }

    @Test("Accent tokens — base opaque, soft 0.15, border 0.35")
    func accentTiers() {
        let base = resolve(Color.fogAccent)
        let soft = resolve(Color.fogAccentSoft)
        let border = resolve(Color.fogAccentBorder)
        #expect(approx(Double(base.opacity), 1.0))
        #expect(approx(Double(soft.opacity), 0.15))
        #expect(approx(Double(border.opacity), 0.35))
        // All three must share the same RGB: 10/132/255
        #expect(approx(Double(base.red), 10.0 / 255.0))
        #expect(approx(Double(soft.red), 10.0 / 255.0))
        #expect(approx(Double(border.red), 10.0 / 255.0))
    }

    @Test("Status colors match hex values from prototype")
    func statusHexValues() {
        let green = resolve(Color.fogGreen)
        #expect(approx(Double(green.red), 0x30 / 255.0))
        #expect(approx(Double(green.green), 0xD1 / 255.0))
        #expect(approx(Double(green.blue), 0x58 / 255.0))

        let red = resolve(Color.fogRed)
        #expect(approx(Double(red.red), 0xFF / 255.0))
        #expect(approx(Double(red.green), 0x45 / 255.0))
        #expect(approx(Double(red.blue), 0x3A / 255.0))
    }
}

// MARK: - Helpers

@MainActor
private func resolve(_ color: Color) -> Color.Resolved {
    color.resolve(in: EnvironmentValues())
}

private func approx(_ a: Double, _ b: Double, epsilon: Double = 0.005) -> Bool {
    abs(a - b) < epsilon
}

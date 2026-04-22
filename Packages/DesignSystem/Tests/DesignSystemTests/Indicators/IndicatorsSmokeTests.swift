import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Indicators — pulse surfaces render cleanly")
struct IndicatorsSmokeTests {

    @Test("RecPulseDot renders at default + custom size")
    func recPulseDot() {
        for size in [CGFloat(7), 12] {
            let view = RecPulseDot(size: size)
                .frame(width: 40, height: 40)
            let renderer = ImageRenderer(content: view)
            #if canImport(UIKit)
            #expect(renderer.uiImage != nil)
            #else
            #expect(renderer.nsImage != nil)
            #endif
        }
    }

    @Test("LocationPulseRing renders")
    func locationPulseRing() {
        let view = LocationPulseRing()
            .frame(width: 80, height: 80)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("fogHexGlow modifier attaches cleanly")
    func hexGlowModifier() {
        let view = Rectangle()
            .fill(Color.fogAccent)
            .frame(width: 40, height: 40)
            .fogHexGlow()
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }
}

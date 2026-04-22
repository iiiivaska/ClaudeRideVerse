import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Primitives — smoke renders under ImageRenderer")
struct PrimitivesSmokeTests {

    @Test("MonoLabel renders into a non-empty bitmap")
    func monoLabelRenders() {
        let view = MonoLabel("Distance")
            .frame(width: 120, height: 20)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("MonoVal renders at each size without crashing")
    func monoValAllSizes() {
        for size in [MonoVal.Size.xl, .lg, .md, .sm] {
            let view = MonoVal("42.0", size: size)
                .frame(width: 200, height: 40)
            let renderer = ImageRenderer(content: view)
            #if canImport(UIKit)
            #expect(renderer.uiImage != nil)
            #else
            #expect(renderer.nsImage != nil)
            #endif
        }
    }

    @Test("GlassPill hosts child content")
    func glassPillHosts() {
        let view = GlassPill {
            MonoVal("12.3", size: .md)
            MonoLabel("km")
        }
        .frame(width: 160, height: 48)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("GlassCircle defaults to 36pt and accepts custom size")
    func glassCircleSizes() {
        #expect(GlassCircle<EmptyView>.defaultSize == 36)
        let view = GlassCircle(size: 44) {
            Image(systemName: "xmark")
        }
        .frame(width: 48, height: 48)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }
}

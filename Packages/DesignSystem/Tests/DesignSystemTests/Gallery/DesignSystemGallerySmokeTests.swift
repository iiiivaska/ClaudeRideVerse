import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("DesignSystemGallery — public embed point renders")
struct DesignSystemGallerySmokeTests {

    @Test("Gallery root renders inside a NavigationStack")
    func galleryRootRenders() {
        let view = NavigationStack {
            DesignSystemGallery()
        }
        .frame(width: 402, height: 874)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("HexGlowPulseExample public helper renders")
    func hexGlowExampleRenders() {
        let view = HexGlowPulseExample()
            .frame(width: 80, height: 80)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }
}

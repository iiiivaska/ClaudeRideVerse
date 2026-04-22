import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Buttons — smoke render + style API")
struct ButtonsSmokeTests {

    @Test("PrimaryButton style composes and renders")
    func primaryStyle() {
        let view = Button("Start Ride") { }
            .buttonStyle(.fogPrimary)
            .frame(width: 320)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("SecondaryButton style composes and renders")
    func secondaryStyle() {
        let view = Button("Not now") { }
            .buttonStyle(.fogSecondary)
            .frame(width: 320)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("LinkButton style composes and renders")
    func linkStyle() {
        let view = Button("I have an account") { }
            .buttonStyle(.fogLink)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("StopButton defaults to 60pt and accepts custom size")
    func stopButtonSizes() {
        #expect(StopButton.defaultSize == 60)
        let view = StopButton(size: 80) { }
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("Concrete styles construct without parameters")
    func styleApiPresence() {
        _ = FogPrimaryButtonStyle()
        _ = FogSecondaryButtonStyle()
        _ = FogLinkButtonStyle()
    }
}

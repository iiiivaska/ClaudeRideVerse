import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Onboarding — dots + icon container")
struct OnboardingTests {

    @Test("OnboardingDots renders at every position")
    func dotsRenderAtEveryIndex() {
        for index in 0..<4 {
            let view = OnboardingDots(activeIndex: index, total: 4)
            let renderer = ImageRenderer(content: view)
            #if canImport(UIKit)
            #expect(renderer.uiImage != nil)
            #else
            #expect(renderer.nsImage != nil)
            #endif
        }
    }

    @Test("OBIconContainer supports both tones")
    func iconContainerTones() {
        for tone in [OBIconContainer<Image>.Tone.accent, .red] {
            let view = OBIconContainer(tone: tone) {
                Image(systemName: "location.fill")
            }
            let renderer = ImageRenderer(content: view)
            #if canImport(UIKit)
            #expect(renderer.uiImage != nil)
            #else
            #expect(renderer.nsImage != nil)
            #endif
        }
    }
}

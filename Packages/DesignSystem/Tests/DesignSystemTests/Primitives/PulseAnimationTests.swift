import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("PulseAnimation — period constants + modifier applies cleanly")
struct PulseAnimationTests {

    @Test("Each pulse style exposes the prototype's cycle duration")
    func cycleDurations() {
        #expect(PulseStyle.red.period == 1.5)
        #expect(PulseStyle.accent.period == 2.0)
        #expect(PulseStyle.hexGlow.period == 1.8)
    }

    @Test("All cases covered by CaseIterable")
    func allCasesCovered() {
        #expect(PulseStyle.allCases.count == 3)
    }

    @Test("fogPulse modifier renders into bitmap at each style")
    func modifierRenders() {
        for style in PulseStyle.allCases {
            let view = Circle()
                .fill(Color.fogAccent)
                .frame(width: 20, height: 20)
                .fogPulse(style)
            let renderer = ImageRenderer(content: view)
            #if canImport(UIKit)
            #expect(renderer.uiImage != nil)
            #else
            #expect(renderer.nsImage != nil)
            #endif
        }
    }
}

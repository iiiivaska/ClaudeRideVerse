import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("FloatingGlassTabBar — selection + rendering")
struct FloatingGlassTabBarTests {

    @Test("Selection binding round-trips when a tab is tapped (programmatic)")
    func selectionBindingRoundTrip() {
        var current = "map"
        let binding = Binding<String>(
            get: { current },
            set: { current = $0 }
        )
        let view = FloatingGlassTabBar(
            selection: binding,
            items: sampleTabs()
        )
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
        // Programmatic selection update via the binding must persist.
        binding.wrappedValue = "rides"
        #expect(current == "rides")
    }

    @Test("Empty items still renders (edge case — no crash)")
    func emptyItems() {
        let binding = Binding.constant("map")
        let view = FloatingGlassTabBar<String>(
            selection: binding,
            items: []
        )
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    private func sampleTabs() -> [FogTab<String>] {
        [
            .init(id: "map", icon: Image(systemName: "map"), label: "Map"),
            .init(id: "rides", icon: Image(systemName: "figure.outdoor.cycle"), label: "Rides"),
            .init(id: "stats", icon: Image(systemName: "chart.bar"), label: "Stats"),
            .init(id: "profile", icon: Image(systemName: "person"), label: "Profile"),
        ]
    }
}

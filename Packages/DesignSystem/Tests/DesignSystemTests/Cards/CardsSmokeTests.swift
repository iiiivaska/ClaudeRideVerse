import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Cards — smoke renders under ImageRenderer")
struct CardsSmokeTests {

    @Test("GlassHUDCard wraps arbitrary content")
    func glassHUDCardRenders() {
        let view = GlassHUDCard {
            MonoVal("42", size: .xl)
        }
        .frame(width: 280, height: 72)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("MetricCell4Grid requires exactly 4 cells and renders")
    func metricGridRenders() {
        let cells: [MetricCell4Grid.Cell] = [
            .init(value: "18.3", label: "km/h"),
            .init(value: "342", label: "hex"),
            .init(value: "1:23", label: "moving"),
            .init(value: "+47", label: "elev"),
        ]
        let view = MetricCell4Grid(cells: cells)
            .frame(width: 340, height: 72)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("StatCard2x2 renders with four cells and hairline separators")
    func statCardRenders() {
        let cells: [StatCard2x2.Cell] = [
            .init(value: "18.3", label: "distance"),
            .init(value: "342", label: "hex"),
            .init(value: "1:23", label: "moving"),
            .init(value: "+47", label: "elev"),
        ]
        let view = StatCard2x2(cells: cells)
            .frame(width: 340, height: 200)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("GroupedCard hosts arbitrary list-like content")
    func groupedCardRenders() {
        let view = GroupedCard {
            VStack(spacing: 0) {
                Text("Row 1").padding()
                Divider()
                Text("Row 2").padding()
            }
        }
        .frame(width: 320)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }

    @Test("UpsellCard renders with gradient + accent border")
    func upsellCardRenders() {
        let view = UpsellCard {
            VStack(alignment: .leading) {
                Text("Premium").padding()
            }
        }
        .frame(width: 320, height: 160)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }
}

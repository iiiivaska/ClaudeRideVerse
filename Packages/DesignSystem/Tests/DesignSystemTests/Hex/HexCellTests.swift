import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("HexCell — all 4 states render + HexGridIllustration layout")
struct HexCellTests {

    @Test("Every HexCellState renders into a non-empty bitmap")
    func allStatesRender() {
        for state in HexCellState.allCases {
            let view = HexCell(state: state, radius: 20)
            let renderer = ImageRenderer(content: view)
            #if canImport(UIKit)
            #expect(renderer.uiImage != nil)
            #else
            #expect(renderer.nsImage != nil)
            #endif
        }
    }

    @Test("HexCellState.allCases covers exactly 4 cases")
    func caseCount() {
        #expect(HexCellState.allCases.count == 4)
    }

    @Test("HexGridIllustration renders without crashing")
    func illustrationRenders() {
        let view = HexGridIllustration(radius: 15)
        let renderer = ImageRenderer(content: view)
        #if canImport(UIKit)
        #expect(renderer.uiImage != nil)
        #else
        #expect(renderer.nsImage != nil)
        #endif
    }
}

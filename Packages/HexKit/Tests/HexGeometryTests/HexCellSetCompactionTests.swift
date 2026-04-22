import CoreLocation
import Testing

import HexCore
@testable import HexGeometry

private let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

@Suite("HexCellSet Compaction")
struct HexCellSetCompactionTests {

    // MARK: - Core compaction

    @Test func sevenR9CompactToOneR8() throws {
        // Get a cell and its parent, then get all siblings from that parent.
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        guard let parent = cell.parent(at: .r8) else {
            Issue.record("Could not get r8 parent")
            return
        }
        let children = parent.children(at: .r9)
        #expect(!children.isEmpty)

        let set = HexCellSet(children)
        let compacted = set.compacted()

        // All 7 children should compact into 1 r8 cell
        #expect(compacted.count == 1)
        #expect(compacted.contains(parent))
    }

    @Test func partialChildrenNoCompaction() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        guard let parent = cell.parent(at: .r8) else {
            Issue.record("Could not get r8 parent")
            return
        }
        // Take only 6 of 7 children — should NOT compact
        var children = parent.children(at: .r9)
        children.remove(children.first!)

        let set = HexCellSet(children)
        let compacted = set.compacted()
        #expect(compacted.count == children.count)
    }

    @Test func emptySetCompacts() {
        let set = HexCellSet()
        let compacted = set.compacted()
        #expect(compacted.isEmpty)
    }

    @Test func singleCellNoCompaction() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))
        let compacted = set.compacted()
        #expect(compacted.count == 1)
        #expect(compacted.contains(cell))
    }

    @Test func compactedIdempotent() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        guard let parent = cell.parent(at: .r8) else {
            Issue.record("Could not get r8 parent")
            return
        }
        let children = parent.children(at: .r9)
        let set = HexCellSet(children)

        let once = set.compacted()
        let twice = once.compacted()
        #expect(once == twice)
    }

    // MARK: - Pentagon edge cases

    @Test func pentagonCompactionDoesNotCrash() throws {
        // Pentagon base cells at r0 (12 known pentagons)
        let pentagonBaseCells: [Int32] = [4, 14, 24, 38, 49, 58, 63, 72, 83, 97, 107, 117]

        // Pick the first pentagon, get its r1 children
        let base = pentagonBaseCells[0]
        let r0Index = constructR0Index(baseCell: base)
        guard let pentagonR0 = HexCell(index: r0Index) else {
            Issue.record("Could not create pentagon cell at r0")
            return
        }
        #expect(pentagonR0.isPentagon)

        // Get children at r1 (pentagons have 6 children: 1 center + 5 edges)
        let children = pentagonR0.children(at: .r1)
        guard !children.isEmpty else {
            Issue.record("Pentagon has no children at r1")
            return
        }

        // Compacting all children should produce 1 r0 cell
        let set = HexCellSet(children)
        let compacted = set.compacted()
        #expect(compacted.count == 1)
    }

    @Test func mixedResolutionGraceful() throws {
        let cellR8 = try HexCell(coordinate: sfCoord, resolution: .r8)
        let cellR9 = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cellR8, cellR9]))

        // SwiftyH3 compactCells may fail on mixed resolutions;
        // should return self unchanged rather than crash
        let compacted = set.compacted()
        #expect(compacted.count >= 1)
    }

    // MARK: - Helpers

    /// Constructs an r0 H3 index from a base cell number.
    /// Format: mode=1 (bits 59-63), res=0 (bits 52-55), base cell (bits 45-51), all digits=7
    private func constructR0Index(baseCell: Int32) -> UInt64 {
        var index: UInt64 = 0x0800_0000_0000_0000 // mode = 1
        // Resolution = 0 (bits 52-55 already 0)
        index |= UInt64(baseCell) << 45
        // Fill all 15 digit slots with 7 (center digit, 3 bits each)
        for i: UInt64 in 0..<15 {
            index |= 7 << (i * 3)
        }
        return index
    }
}

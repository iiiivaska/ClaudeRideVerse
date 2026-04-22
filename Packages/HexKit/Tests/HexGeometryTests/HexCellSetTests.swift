import CoreLocation
import Testing

import HexCore
@testable import HexGeometry

// MARK: - San Francisco fixture

private let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

@Suite("HexCellSet")
struct HexCellSetTests {

    @Test func initEmpty() {
        let set = HexCellSet()
        #expect(set.count == 0)
        #expect(set.isEmpty)
    }

    @Test func initFromSet() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))
        #expect(set.count == 1)
        #expect(!set.isEmpty)
    }

    @Test func initFromSequenceDeduplicates() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet([cell, cell, cell])
        #expect(set.count == 1)
    }

    @Test func insertNewCell() throws {
        var set = HexCellSet()
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let inserted = set.insert(cell)
        #expect(inserted)
        #expect(set.count == 1)
    }

    @Test func insertDuplicate() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        var set = HexCellSet(Set([cell]))
        let inserted = set.insert(cell)
        #expect(!inserted)
        #expect(set.count == 1)
    }

    @Test func insertContentsOf() throws {
        let cell1 = try HexCell(coordinate: sfCoord, resolution: .r9)
        let nyCoord = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let cell2 = try HexCell(coordinate: nyCoord, resolution: .r9)
        var set = HexCellSet()
        set.insert(contentsOf: [cell1, cell2])
        #expect(set.count == 2)
    }

    @Test func contains() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let nyCoord = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let other = try HexCell(coordinate: nyCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))
        #expect(set.contains(cell))
        #expect(!set.contains(other))
    }

    @Test func cellsProperty() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))
        #expect(set.cells.count == 1)
        #expect(set.cells.contains(cell))
    }

    @Test func mergedDisjoint() throws {
        let cell1 = try HexCell(coordinate: sfCoord, resolution: .r9)
        let nyCoord = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let cell2 = try HexCell(coordinate: nyCoord, resolution: .r9)
        let set1 = HexCellSet(Set([cell1]))
        let set2 = HexCellSet(Set([cell2]))
        let merged = set1.merged(with: set2)
        #expect(merged.count == 2)
    }

    @Test func mergedOverlapping() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set1 = HexCellSet(Set([cell]))
        let set2 = HexCellSet(Set([cell]))
        let merged = set1.merged(with: set2)
        #expect(merged.count == 1)
    }

    @Test func mergedWithEmpty() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))
        let merged = set.merged(with: HexCellSet())
        #expect(merged.count == 1)
    }

    @Test func equatable() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set1 = HexCellSet(Set([cell]))
        let set2 = HexCellSet(Set([cell]))
        #expect(set1 == set2)
    }
}

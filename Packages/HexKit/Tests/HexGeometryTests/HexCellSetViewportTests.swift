import CoreLocation
import Testing

import HexCore
@testable import HexGeometry

private let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
private let nyCoord = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)

@Suite("HexCellSet Viewport Culling")
struct HexCellSetViewportTests {

    // SF area bbox
    private let sfBBox = HexBBox(south: 37.7, west: -122.5, north: 37.85, east: -122.35)

    @Test func cellsInBboxContained() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let neighbors = cell.immediateNeighbors
        let set = HexCellSet(neighbors.union([cell]))

        let result = set.cells(in: sfBBox)
        // All SF cells should be within SF bbox
        #expect(result.count == set.count)
    }

    @Test func cellsOutsideBboxExcluded() throws {
        let nyCell = try HexCell(coordinate: nyCoord, resolution: .r9)
        let set = HexCellSet(Set([nyCell]))

        let result = set.cells(in: sfBBox)
        #expect(result.isEmpty)
    }

    @Test func bufferIncludesEdgeCells() throws {
        // Create a tight bbox around SF center, then place a cell slightly outside
        let tightBBox = HexBBox(south: 37.774, west: -122.420, north: 37.776, east: -122.418)

        // Cell at center is inside
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))

        // Even if cell center falls slightly outside the tight bbox,
        // the 50% buffer should include it. The tight bbox is ~0.002 degrees,
        // the buffer adds ~0.001 on each side.
        let result = set.cells(in: tightBBox)
        // SF center (37.7749, -122.4194) should be within the expanded bbox
        let expanded = tightBBox.expanded(by: 0.5)
        let center = try cell.center
        #expect(expanded.contains(center))
        #expect(result.count == 1)
    }

    @Test func emptySetReturnsEmpty() {
        let set = HexCellSet()
        let result = set.cells(in: sfBBox)
        #expect(result.isEmpty)
    }

    @Test func wholeWorldBboxReturnsAll() throws {
        let sfCell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let nyCell = try HexCell(coordinate: nyCoord, resolution: .r9)
        let set = HexCellSet(Set([sfCell, nyCell]))

        let world = HexBBox(south: -90, west: -180, north: 90, east: 180)
        let result = set.cells(in: world)
        #expect(result.count == 2)
    }

    @Test func disjointLocationsPartialReturn() throws {
        let sfCell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let nyCell = try HexCell(coordinate: nyCoord, resolution: .r9)
        let set = HexCellSet(Set([sfCell, nyCell]))

        let result = set.cells(in: sfBBox)
        #expect(result.count == 1)
        #expect(result.contains(sfCell))
        #expect(!result.contains(nyCell))
    }
}

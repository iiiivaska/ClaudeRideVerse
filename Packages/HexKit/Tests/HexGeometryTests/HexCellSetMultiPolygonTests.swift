import CoreLocation
import Testing

import HexCore
@testable import HexGeometry

private let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

@Suite("HexCellSet MultiPolygon")
struct HexCellSetMultiPolygonTests {

    @Test func singleCellBoundary() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))
        let mp = set.multiPolygon()

        #expect(mp.polygons.count == 1)
        // Hexagon has 6 vertices + closing vertex = 7 points
        #expect(mp.polygons[0].outer.count >= 6)
    }

    @Test func clusterBoundary() throws {
        // Center cell + 6 immediate neighbors = 7 cells
        let center = try HexCell(coordinate: sfCoord, resolution: .r9)
        let cluster = center.immediateNeighbors.union([center])
        #expect(cluster.count == 7) // hex: 1 center + 6

        let set = HexCellSet(cluster)
        let mp = set.multiPolygon()

        // Contiguous cluster should produce exactly 1 polygon
        #expect(mp.polygons.count == 1)
        #expect(mp.polygons[0].outer.count >= 6)
    }

    @Test func hundredHexPolygonCount() throws {
        // Build ~100 contiguous cells using k=5 disk around SF
        let center = try HexCell(coordinate: sfCoord, resolution: .r9)
        let disk = center.neighbors(within: 5).union([center])
        #expect(disk.count >= 50) // k=5 disk is ~91 cells

        let set = HexCellSet(disk)
        let mp = set.multiPolygon()

        // Contiguous disk should produce a small number of polygons (typically 1)
        #expect(!mp.isEmpty)
        #expect(mp.polygons.count >= 1)
    }

    @Test func disjointClustersMultiplePolygons() throws {
        // SF and NY are far apart — should produce separate polygons
        let sfCell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let nyCoord = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let nyCell = try HexCell(coordinate: nyCoord, resolution: .r9)

        let set = HexCellSet(Set([sfCell, nyCell]))
        let mp = set.multiPolygon()

        #expect(mp.polygons.count == 2)
    }

    @Test func emptySetEmptyMultiPolygon() {
        let set = HexCellSet()
        let mp = set.multiPolygon()
        #expect(mp.isEmpty)
    }

    @Test func outerBoundariesMatchesPolygonCount() throws {
        let cell = try HexCell(coordinate: sfCoord, resolution: .r9)
        let set = HexCellSet(Set([cell]))

        let mp = set.multiPolygon()
        let flat = set.outerBoundaries

        #expect(flat.count == mp.polygons.count)
    }
}

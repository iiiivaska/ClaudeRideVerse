import CoreLocation
import Testing

@testable import HexCore

// MARK: - HexResolution Tests

@Suite("HexResolution")
struct HexResolutionTests {

    @Test func allCasesHas16Resolutions() {
        #expect(HexResolution.allCases.count == 16)
    }

    @Test func comparable() {
        #expect(HexResolution.r0 < HexResolution.r9)
        #expect(HexResolution.r9 < HexResolution.r15)
        #expect(!(HexResolution.r5 < HexResolution.r5))
    }

    @Test func averageEdgeMetersR0() {
        // r0 ~1107 km
        let edge = HexResolution.r0.averageEdgeMeters
        #expect(edge > 1_000_000 && edge < 1_200_000)
    }

    @Test func averageEdgeMetersR9() {
        // r9 ~174 m
        let edge = HexResolution.r9.averageEdgeMeters
        #expect(edge > 170 && edge < 180)
    }

    @Test func averageAreaR9() {
        // r9 ~105,332 m²
        let area = HexResolution.r9.averageAreaSquareMeters
        #expect(area > 100_000 && area < 110_000)
    }

    @Test func edgeLengthDecreasesWithResolution() {
        for i in 1..<HexResolution.allCases.count {
            let coarser = HexResolution.allCases[i - 1]
            let finer = HexResolution.allCases[i]
            #expect(coarser.averageEdgeMeters > finer.averageEdgeMeters)
        }
    }
}

// MARK: - HexCell Init Tests

@Suite("HexCell Init")
struct HexCellInitTests {

    // San Francisco city center
    private static let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    @Test func initFromCoordinate() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(cell.resolution == .r9)
        #expect(cell.index != 0)
    }

    @Test func initFromValidIndex() throws {
        let original = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        let restored = HexCell(index: original.index)
        #expect(restored != nil)
        #expect(restored?.index == original.index)
        #expect(restored?.resolution == .r9)
    }

    @Test func initFromInvalidIndex() {
        #expect(HexCell(index: 0) == nil)
        #expect(HexCell(index: UInt64.max) == nil)
    }

    @Test func descriptionIsHexString() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(!cell.description.isEmpty)
        #expect(cell.description.count > 10)
    }

    @Test func sameCoordinateProducesSameCell() throws {
        let cell1 = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        let cell2 = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(cell1 == cell2)
    }

    @Test func differentResolutionsProduceDifferentCells() throws {
        let r8 = try HexCell(coordinate: Self.sfCoord, resolution: .r8)
        let r9 = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(r8.index != r9.index)
    }
}

// MARK: - HexCell Properties Tests

@Suite("HexCell Properties")
struct HexCellPropertiesTests {

    private static let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    @Test func centerIsCloseToOriginalCoordinate() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        let center = try cell.center
        let latDiff = abs(center.latitude - Self.sfCoord.latitude)
        let lonDiff = abs(center.longitude - Self.sfCoord.longitude)
        #expect(latDiff < 0.01)
        #expect(lonDiff < 0.01)
    }

    @Test func hexagonBoundaryHas6Vertices() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        if !cell.isPentagon {
            let verts = try cell.boundary
            #expect(verts.count == 6)
        }
    }

    @Test func nonPentagonAtR9() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(!cell.isPentagon)
    }
}

// MARK: - HexCell Pentagon Tests

@Suite("HexCell Pentagon")
struct HexCellPentagonTests {

    @Test func pentagonCountAtR0() throws {
        let pentagons = findPentagonsAtR0()
        #expect(pentagons.count == 12)
    }

    @Test func pentagonIsPentagon() throws {
        for cell in findPentagonsAtR0() {
            #expect(cell.isPentagon)
        }
    }

    @Test func pentagonHas5Neighbors() throws {
        guard let pentagon = findPentagonsAtR0().first else {
            Issue.record("No pentagons found")
            return
        }
        #expect(pentagon.immediateNeighbors.count == 5)
    }

    @Test func pentagonBoundaryHas5Vertices() throws {
        guard let pentagon = findPentagonsAtR0().first else {
            Issue.record("No pentagons found")
            return
        }
        let verts = try pentagon.boundary
        #expect(verts.count == 5)
    }

    /// Finds all 12 pentagons at resolution 0 by scanning all 122 base cells.
    private func findPentagonsAtR0() -> [HexCell] {
        // Known pentagon base cell numbers: 4, 14, 24, 38, 49, 58, 63, 72, 83, 97, 107, 117
        let pentagonBases: [Int] = [4, 14, 24, 38, 49, 58, 63, 72, 83, 97, 107, 117]
        return pentagonBases.compactMap { base in
            let index = constructR0Index(baseCell: base)
            return HexCell(index: index)
        }
    }

    private func constructR0Index(baseCell: Int) -> UInt64 {
        // H3 index: mode=1 (cell), resolution=0, base cell, remaining digits all 7
        var index: UInt64 = 0
        index |= (1 << 59)  // mode = 1
        index |= UInt64(baseCell) << 45
        // Fill 15 digit slots (3 bits each, bits 0-44) with 7
        for i in 0..<15 {
            index |= (7 << (i * 3))
        }
        return index
    }
}

// MARK: - HexCell Hierarchy Tests

@Suite("HexCell Hierarchy")
struct HexCellHierarchyTests {

    private static let sfCoord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)

    @Test func hexagonHas6ImmediateNeighbors() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(!cell.isPentagon)
        #expect(cell.immediateNeighbors.count == 6)
    }

    @Test func neighborsDoNotIncludeSelf() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(!cell.immediateNeighbors.contains(cell))
    }

    @Test func parentAtCoarserResolution() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        let parent = cell.parent(at: .r8)
        #expect(parent != nil)
        #expect(parent?.resolution == .r8)
    }

    @Test func parentAtSameResolutionReturnsNil() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(cell.parent(at: .r9) == nil)
    }

    @Test func parentAtFinerResolutionReturnsNil() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(cell.parent(at: .r10) == nil)
    }

    @Test func childrenAtFinerResolution() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r8)
        let kids = cell.children(at: .r9)
        #expect(kids.count == 7)
    }

    @Test func childrenAtSameResolutionReturnsEmpty() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(cell.children(at: .r9).isEmpty)
    }

    @Test func parentChildRoundtrip() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        guard let parent = cell.parent(at: .r8) else {
            Issue.record("Parent should exist")
            return
        }
        let children = parent.children(at: .r9)
        #expect(children.contains(cell))
    }

    @Test func gridDistanceOfAdjacentCells() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        guard let neighbor = cell.immediateNeighbors.first else {
            Issue.record("Should have neighbors")
            return
        }
        #expect(cell.gridDistance(to: neighbor) == 1)
    }

    @Test func gridDistanceToSelf() throws {
        let cell = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(cell.gridDistance(to: cell) == 0)
    }

    @Test func gridDistanceDifferentResolutionsReturnsNil() throws {
        let r8 = try HexCell(coordinate: Self.sfCoord, resolution: .r8)
        let r9 = try HexCell(coordinate: Self.sfCoord, resolution: .r9)
        #expect(r8.gridDistance(to: r9) == nil)
    }
}

// MARK: - HexCellBatch Tests

@Suite("HexCellBatch")
struct HexCellBatchTests {

    @Test func cellsFromCoordinatesDeduplicates() {
        let coord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let cells = HexCellBatch.cells(for: [coord, coord], resolution: .r9)
        #expect(cells.count == 1)
    }

    @Test func cellsFromMultipleCoordinates() {
        let sf = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let ny = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        let cells = HexCellBatch.cells(for: [sf, ny], resolution: .r9)
        #expect(cells.count == 2)
    }

    @Test func boundaryOfCluster() throws {
        let cell = try HexCell(
            coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
            resolution: .r9
        )
        var cluster = cell.immediateNeighbors
        cluster.insert(cell)

        let boundary = HexCellBatch.boundary(of: cluster)
        #expect(!boundary.isEmpty)
        #expect(!boundary.polygons.isEmpty)
        #expect(!boundary.polygons[0].outer.isEmpty)
    }

    @Test func boundaryOfEmptySet() {
        let boundary = HexCellBatch.boundary(of: [])
        #expect(boundary.isEmpty)
    }
}

import CoreLocation
import Foundation
import HexCore
import HexGeometry
import MapCore
import Testing

@testable import MapFogOfWar

// MARK: - Test Helpers

/// Mock VisitedCells that returns a fixed cell set.
struct MockVisitedCells: VisitedCells {
    let cells: HexCellSet

    func cellSet(in bbox: MapBBox, atZoom zoom: Double) -> HexCellSet {
        cells
    }
}

/// Creates a HexCellSet from coordinates at the given resolution.
private func makeCellSet(
    coordinates: [(lat: Double, lon: Double)],
    resolution: HexResolution = .r9
) throws -> HexCellSet {
    var set = HexCellSet()
    for coord in coordinates {
        let cell = try HexCell(
            coordinate: CLLocationCoordinate2D(
                latitude: coord.lat, longitude: coord.lon
            ),
            resolution: resolution
        )
        set.insert(cell)
    }
    return set
}

// MARK: - FogResolutionPolicy Tests

@Suite("FogResolutionPolicy")
struct FogResolutionPolicyTests {

    @Test func highZoomReturnsR10() {
        #expect(FogResolutionPolicy.resolution(forZoom: 14) == .r10)
        #expect(FogResolutionPolicy.resolution(forZoom: 18) == .r10)
        #expect(FogResolutionPolicy.resolution(forZoom: 20) == .r10)
    }

    @Test func mediumZoomReturnsR8orR9() {
        #expect(FogResolutionPolicy.resolution(forZoom: 12) == .r9)
        #expect(FogResolutionPolicy.resolution(forZoom: 13) == .r9)
        #expect(FogResolutionPolicy.resolution(forZoom: 10) == .r8)
        #expect(FogResolutionPolicy.resolution(forZoom: 11) == .r8)
    }

    @Test func lowZoomReturnsCoarseResolution() {
        #expect(FogResolutionPolicy.resolution(forZoom: 9) == .r7)
        #expect(FogResolutionPolicy.resolution(forZoom: 7) == .r6)
        #expect(FogResolutionPolicy.resolution(forZoom: 5) == .r5)
        #expect(FogResolutionPolicy.resolution(forZoom: 3) == .r4)
        #expect(FogResolutionPolicy.resolution(forZoom: 1) == .r3)
    }

    @Test func boundaryZoom14IsR10() {
        #expect(FogResolutionPolicy.resolution(forZoom: 14) == .r10)
    }

    @Test func justBelow14IsR9() {
        #expect(FogResolutionPolicy.resolution(forZoom: 13.99) == .r9)
    }
}

// MARK: - FogStyle Tests

@Suite("FogStyle")
struct FogStyleTests {

    @Test func defaultValues() {
        let style = FogStyle.default
        #expect(style.fogColor == .black)
        #expect(style.opacity == 0.7)
        #expect(style.edgeColor == nil)
        #expect(style.pulseNewCells == true)
    }

    @Test func customValues() {
        let style = FogStyle(
            fogColor: .blue, opacity: 0.5,
            edgeColor: .white, pulseNewCells: false
        )
        #expect(style.fogColor == .blue)
        #expect(style.opacity == 0.5)
        #expect(style.edgeColor == .white)
        #expect(style.pulseNewCells == false)
    }

    @Test func equality() {
        let a = FogStyle(fogColor: .black, opacity: 0.7, edgeColor: nil, pulseNewCells: true)
        let b = FogStyle.default
        #expect(a == b)
    }

    @Test func inequality() {
        #expect(FogStyle.default != FogStyle(fogColor: .red))
    }
}

// MARK: - FogGeoJSONBuilder Tests

@Suite("FogGeoJSONBuilder")
struct FogGeoJSONBuilderTests {

    @Test func emptyFogCoversWorld() throws {
        let data = FogGeoJSONBuilder.buildEmptyFogGeoJSON()
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        #expect(json["type"] as? String == "Feature")

        let geometry = try #require(json["geometry"] as? [String: Any])
        #expect(geometry["type"] as? String == "Polygon")

        let coordinates = try #require(geometry["coordinates"] as? [[[Double]]])
        #expect(coordinates.count == 1) // world exterior only, no holes
        #expect(coordinates[0].count == 5) // closed ring: 4 corners + repeat
    }

    @Test func singleVisitedGroupBecomesOneHole() throws {
        let triangle = HexMultiPolygon.Polygon(
            outer: [
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
                CLLocationCoordinate2D(latitude: 52.38, longitude: 4.90),
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.91),
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
            ]
        )
        let multi = HexMultiPolygon(polygons: [triangle])

        let data = FogGeoJSONBuilder.buildGeoJSON(from: multi)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        #expect(geometry["type"] as? String == "MultiPolygon")

        let coords = try #require(geometry["coordinates"] as? [[[[Double]]]])
        #expect(coords.count == 1) // one polygon
        #expect(coords[0].count == 2) // world ring + one hole
    }

    @Test func multipleGroupsBecomeMultipleHoles() throws {
        let amsterdam = HexMultiPolygon.Polygon(
            outer: [
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
                CLLocationCoordinate2D(latitude: 52.38, longitude: 4.90),
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
            ]
        )
        let paris = HexMultiPolygon.Polygon(
            outer: [
                CLLocationCoordinate2D(latitude: 48.85, longitude: 2.34),
                CLLocationCoordinate2D(latitude: 48.86, longitude: 2.35),
                CLLocationCoordinate2D(latitude: 48.85, longitude: 2.34),
            ]
        )
        let multi = HexMultiPolygon(polygons: [amsterdam, paris])

        let data = FogGeoJSONBuilder.buildGeoJSON(from: multi)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        let coords = try #require(geometry["coordinates"] as? [[[[Double]]]])
        #expect(coords.count == 1) // one main polygon
        #expect(coords[0].count == 3) // world + 2 holes
    }

    @Test func innerHolesBecomeRefogPatches() throws {
        let polygon = HexMultiPolygon.Polygon(
            outer: [
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
                CLLocationCoordinate2D(latitude: 52.39, longitude: 4.92),
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.95),
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
            ],
            holes: [[
                CLLocationCoordinate2D(latitude: 52.375, longitude: 4.91),
                CLLocationCoordinate2D(latitude: 52.38, longitude: 4.92),
                CLLocationCoordinate2D(latitude: 52.375, longitude: 4.93),
                CLLocationCoordinate2D(latitude: 52.375, longitude: 4.91),
            ]]
        )
        let multi = HexMultiPolygon(polygons: [polygon])

        let data = FogGeoJSONBuilder.buildGeoJSON(from: multi)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        let coords = try #require(geometry["coordinates"] as? [[[[Double]]]])
        #expect(coords.count == 2) // main fog + 1 re-fog patch
        #expect(coords[0].count == 2) // world exterior + visited outer hole
        #expect(coords[1].count == 1) // re-fog patch ring
    }

    @Test func emptyMultiPolygonProducesFullFog() throws {
        let multi = HexMultiPolygon(polygons: [])
        let data = FogGeoJSONBuilder.buildGeoJSON(from: multi)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        #expect(geometry["type"] as? String == "Polygon") // full fog, no MultiPolygon
    }

    @Test func coordinatesUseLongitudeLatitudeOrder() throws {
        let polygon = HexMultiPolygon.Polygon(
            outer: [
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
                CLLocationCoordinate2D(latitude: 52.38, longitude: 4.90),
                CLLocationCoordinate2D(latitude: 52.37, longitude: 4.89),
            ]
        )
        let multi = HexMultiPolygon(polygons: [polygon])

        let data = FogGeoJSONBuilder.buildGeoJSON(from: multi)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        let coords = try #require(geometry["coordinates"] as? [[[[Double]]]])
        let holeRing = coords[0][1] // second ring = visited hole

        // GeoJSON: [longitude, latitude]
        #expect(holeRing[0][0] == 4.89) // longitude first
        #expect(holeRing[0][1] == 52.37) // latitude second
    }
}

// MARK: - FogLayer Tests

@Suite("FogLayer")
struct FogLayerTests {

    @Test func emptyVisitedCellsProduceFullFog() throws {
        let mock = MockVisitedCells(cells: HexCellSet())
        let layer = FogLayer(visited: mock)

        let bbox = MapBBox(
            northEast: CLLocationCoordinate2D(latitude: 53, longitude: 6),
            southWest: CLLocationCoordinate2D(latitude: 52, longitude: 4)
        )
        let data = layer.geoJSON(in: bbox, atZoom: 12)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        #expect(geometry["type"] as? String == "Polygon")
    }

    @Test func visitedCellsCreateHoles() throws {
        let cellSet = try makeCellSet(coordinates: [
            (lat: 52.37, lon: 4.9),
            (lat: 52.371, lon: 4.901),
            (lat: 52.372, lon: 4.902),
        ])
        let mock = MockVisitedCells(cells: cellSet)
        let layer = FogLayer(visited: mock)

        let bbox = MapBBox(
            northEast: CLLocationCoordinate2D(latitude: 53, longitude: 6),
            southWest: CLLocationCoordinate2D(latitude: 52, longitude: 4)
        )
        let data = layer.geoJSON(in: bbox, atZoom: 15)
        let json = try #require(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )

        let geometry = try #require(json["geometry"] as? [String: Any])
        #expect(geometry["type"] as? String == "MultiPolygon")

        let coords = try #require(geometry["coordinates"] as? [[[[Double]]]])
        #expect(coords[0].count >= 2) // world + at least one hole
    }

    @Test func conformsToMapContent() {
        let mock = MockVisitedCells(cells: HexCellSet())
        let layer = FogLayer(visited: mock)
        let _: any MapContent = layer
        #expect(layer.style == .default)
    }

    @Test func customStylePassedThrough() {
        let mock = MockVisitedCells(cells: HexCellSet())
        let style = FogStyle(fogColor: .blue, opacity: 0.5)
        let layer = FogLayer(visited: mock, style: style)
        #expect(layer.style.fogColor == .blue)
        #expect(layer.style.opacity == 0.5)
    }
}

// MARK: - FogUpdateThrottle Tests

@Suite("FogUpdateThrottle")
struct FogUpdateThrottleTests {

    @Test func firstCallAllowsUpdate() async {
        let throttle = FogUpdateThrottle(interval: .seconds(1))
        let result = await throttle.shouldUpdate()
        #expect(result == true)
    }

    @Test func immediateSecondCallBlocked() async {
        let throttle = FogUpdateThrottle(interval: .seconds(10))
        _ = await throttle.shouldUpdate()
        let second = await throttle.shouldUpdate()
        #expect(second == false)
    }

    @Test func resetAllowsImmediateUpdate() async {
        let throttle = FogUpdateThrottle(interval: .seconds(10))
        _ = await throttle.shouldUpdate()
        await throttle.reset()
        let afterReset = await throttle.shouldUpdate()
        #expect(afterReset == true)
    }
}

// MARK: - Module Smoke Test

@Test func mapFogOfWarModuleImports() {
    let _: FogStyle = .default
    let _ = FogResolutionPolicy.resolution(forZoom: 12)
}

import CoreLocation
import Testing
@testable import MapCore

@Suite("MapBBox")
struct MapBBoxTests {

    private let amsterdam = MapBBox(
        northEast: CLLocationCoordinate2D(latitude: 52.42, longitude: 4.95),
        southWest: CLLocationCoordinate2D(latitude: 52.30, longitude: 4.85)
    )

    @Test func containsInsideCoordinate() {
        let inside = CLLocationCoordinate2D(latitude: 52.36, longitude: 4.90)
        #expect(amsterdam.contains(inside))
    }

    @Test func containsBoundaryCoordinate() {
        let corner = CLLocationCoordinate2D(latitude: 52.42, longitude: 4.95)
        #expect(amsterdam.contains(corner))
    }

    @Test func doesNotContainOutsideCoordinate() {
        let outside = CLLocationCoordinate2D(latitude: 53.0, longitude: 5.0)
        #expect(!amsterdam.contains(outside))
    }

    @Test func expandedIncreasesArea() {
        let expanded = amsterdam.expanded(by: 0.5)
        let latSpan = amsterdam.northEast.latitude - amsterdam.southWest.latitude
        let lonSpan = amsterdam.northEast.longitude - amsterdam.southWest.longitude

        let expandedLatSpan = expanded.northEast.latitude - expanded.southWest.latitude
        let expandedLonSpan = expanded.northEast.longitude - expanded.southWest.longitude

        #expect(expandedLatSpan > latSpan)
        #expect(expandedLonSpan > lonSpan)
        // 0.5 factor adds 50% on each side → total span doubles
        #expect(abs(expandedLatSpan - latSpan * 2) < 0.0001)
        #expect(abs(expandedLonSpan - lonSpan * 2) < 0.0001)
    }

    @Test func equality() {
        let copy = MapBBox(
            northEast: CLLocationCoordinate2D(latitude: 52.42, longitude: 4.95),
            southWest: CLLocationCoordinate2D(latitude: 52.30, longitude: 4.85)
        )
        #expect(copy == amsterdam)
    }

    @Test func inequalityOnDifferentCorners() {
        let other = MapBBox(
            northEast: CLLocationCoordinate2D(latitude: 53.0, longitude: 5.0),
            southWest: CLLocationCoordinate2D(latitude: 52.30, longitude: 4.85)
        )
        #expect(other != amsterdam)
    }
}

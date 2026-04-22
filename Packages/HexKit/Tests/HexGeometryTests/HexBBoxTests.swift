import CoreLocation
import Testing

@testable import HexGeometry

@Suite("HexBBox")
struct HexBBoxTests {

    // SF area bbox: roughly 37.7–37.8 lat, -122.5–-122.4 lon
    private let sfBBox = HexBBox(south: 37.7, west: -122.5, north: 37.8, east: -122.4)

    @Test func containsInsideCoordinate() {
        let inside = CLLocationCoordinate2D(latitude: 37.75, longitude: -122.45)
        #expect(sfBBox.contains(inside))
    }

    @Test func doesNotContainOutside() {
        let outside = CLLocationCoordinate2D(latitude: 40.7, longitude: -74.0) // NY
        #expect(!sfBBox.contains(outside))
    }

    @Test func containsEdgeCoordinate() {
        let edge = CLLocationCoordinate2D(latitude: 37.7, longitude: -122.5)
        #expect(sfBBox.contains(edge))
    }

    @Test func expandedByHalf() {
        let expanded = sfBBox.expanded(by: 0.5)
        // Original lat span = 0.1, pad = 0.05 each side
        #expect(expanded.south == 37.7 - 0.05)
        #expect(expanded.north == 37.8 + 0.05)
        // Original lon span = 0.1, pad = 0.05 each side
        #expect(expanded.west == -122.5 - 0.05)
        #expect(expanded.east == -122.4 + 0.05)
    }

    @Test func initFromCornerCoordinates() {
        let sw = CLLocationCoordinate2D(latitude: 37.7, longitude: -122.5)
        let ne = CLLocationCoordinate2D(latitude: 37.8, longitude: -122.4)
        let bbox = HexBBox(sw: sw, ne: ne)
        #expect(bbox == sfBBox)
    }
}

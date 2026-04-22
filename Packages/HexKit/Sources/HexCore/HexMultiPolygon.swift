import CoreLocation

/// A collection of polygons representing the boundary of a set of H3 cells.
public struct HexMultiPolygon: Sendable {

    /// A single polygon with an outer ring and optional holes.
    public struct Polygon: @unchecked Sendable {
        public let outer: [CLLocationCoordinate2D]
        public let holes: [[CLLocationCoordinate2D]]

        public init(outer: [CLLocationCoordinate2D], holes: [[CLLocationCoordinate2D]] = []) {
            self.outer = outer
            self.holes = holes
        }
    }

    public let polygons: [Polygon]

    public init(polygons: [Polygon]) {
        self.polygons = polygons
    }

    public var isEmpty: Bool { polygons.isEmpty }
}

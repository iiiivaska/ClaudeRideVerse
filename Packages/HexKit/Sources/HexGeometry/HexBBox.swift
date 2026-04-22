import CoreLocation

/// Axis-aligned bounding box for viewport culling operations.
///
/// Local to HexGeometry to avoid coupling to MapCore's `MapBBox`.
/// When MapCore is implemented, a bridging extension can convert between the two.
public struct HexBBox: Sendable, Equatable {

    public let south: Double
    public let west: Double
    public let north: Double
    public let east: Double

    public init(south: Double, west: Double, north: Double, east: Double) {
        self.south = south
        self.west = west
        self.north = north
        self.east = east
    }

    /// Creates a bounding box from south-west and north-east corners.
    public init(sw: CLLocationCoordinate2D, ne: CLLocationCoordinate2D) {
        self.south = sw.latitude
        self.west = sw.longitude
        self.north = ne.latitude
        self.east = ne.longitude
    }

    /// Returns a new bbox expanded by the given fraction on each side.
    ///
    /// A fraction of `0.5` expands each edge by 50% of the bbox's span in that dimension.
    /// For example, a 1-degree-wide bbox becomes 2 degrees wide (0.5 added to each side).
    public func expanded(by fraction: Double) -> HexBBox {
        let latSpan = north - south
        let lonSpan = east - west
        let latPad = latSpan * fraction
        let lonPad = lonSpan * fraction
        return HexBBox(
            south: south - latPad,
            west: west - lonPad,
            north: north + latPad,
            east: east + lonPad
        )
    }

    /// Whether the given coordinate falls within this bounding box.
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        coordinate.latitude >= south
            && coordinate.latitude <= north
            && coordinate.longitude >= west
            && coordinate.longitude <= east
    }
}

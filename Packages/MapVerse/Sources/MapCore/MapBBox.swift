import CoreLocation

/// Axis-aligned geographic bounding box defined by its north-east and south-west corners.
public struct MapBBox: Sendable, Equatable {
    public let northEast: CLLocationCoordinate2D
    public let southWest: CLLocationCoordinate2D

    public init(northEast: CLLocationCoordinate2D, southWest: CLLocationCoordinate2D) {
        self.northEast = northEast
        self.southWest = southWest
    }

    /// Whether the given coordinate falls within the bounding box (inclusive).
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        coordinate.latitude >= southWest.latitude
            && coordinate.latitude <= northEast.latitude
            && coordinate.longitude >= southWest.longitude
            && coordinate.longitude <= northEast.longitude
    }

    /// Returns a new bounding box expanded by the given factor in each direction.
    ///
    /// A factor of 0.5 adds 50% of the span on each side (doubling the total area).
    public func expanded(by factor: Double) -> MapBBox {
        let latSpan = northEast.latitude - southWest.latitude
        let lonSpan = northEast.longitude - southWest.longitude
        let latDelta = latSpan * factor
        let lonDelta = lonSpan * factor
        return MapBBox(
            northEast: CLLocationCoordinate2D(
                latitude: northEast.latitude + latDelta,
                longitude: northEast.longitude + lonDelta
            ),
            southWest: CLLocationCoordinate2D(
                latitude: southWest.latitude - latDelta,
                longitude: southWest.longitude - lonDelta
            )
        )
    }

    public static func == (lhs: MapBBox, rhs: MapBBox) -> Bool {
        lhs.northEast.latitude == rhs.northEast.latitude
            && lhs.northEast.longitude == rhs.northEast.longitude
            && lhs.southWest.latitude == rhs.southWest.latitude
            && lhs.southWest.longitude == rhs.southWest.longitude
    }
}

// MARK: - MapLibre Bridging

#if canImport(MapLibre)
import MapLibre

extension MapBBox {
    /// Creates a bounding box from a MapLibre coordinate bounds.
    public init(from bounds: MLNCoordinateBounds) {
        self.init(northEast: bounds.ne, southWest: bounds.sw)
    }

    /// Converts to a MapLibre coordinate bounds.
    public var mlnBounds: MLNCoordinateBounds {
        MLNCoordinateBounds(sw: southWest, ne: northEast)
    }
}
#endif

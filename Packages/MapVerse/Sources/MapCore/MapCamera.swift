import CoreLocation

/// Camera state describing the observer's position and orientation on the map.
///
/// All angles are in degrees. `zoom` follows the Web Mercator convention
/// (0 = whole world, ~22 = building level).
public struct MapCamera: Sendable, Equatable {
    public let center: CLLocationCoordinate2D
    public let zoom: Double
    public let bearing: Double
    public let pitch: Double

    public init(
        center: CLLocationCoordinate2D,
        zoom: Double,
        bearing: Double = 0,
        pitch: Double = 0
    ) {
        self.center = center
        self.zoom = zoom
        self.bearing = bearing
        self.pitch = pitch
    }

    public static func == (lhs: MapCamera, rhs: MapCamera) -> Bool {
        lhs.center.latitude == rhs.center.latitude
            && lhs.center.longitude == rhs.center.longitude
            && lhs.zoom == rhs.zoom
            && lhs.bearing == rhs.bearing
            && lhs.pitch == rhs.pitch
    }
}

// MARK: - Presets

extension MapCamera {
    /// Amsterdam Centraal — default camera for previews and development.
    public static let amsterdam = MapCamera(
        center: CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
        zoom: 13
    )
}

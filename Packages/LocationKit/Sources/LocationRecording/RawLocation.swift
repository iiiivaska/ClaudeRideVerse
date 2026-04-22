import CoreLocation

/// A Sendable snapshot of a single GPS reading.
///
/// Custom struct instead of `CLLocation` because `CLLocation` is not `Sendable`
/// and contains opaque internal state unsuitable for actor boundaries.
public struct RawLocation: Sendable {
    public let coordinate: CLLocationCoordinate2D
    public let altitude: CLLocationDistance
    public let horizontalAccuracy: CLLocationAccuracy
    public let verticalAccuracy: CLLocationAccuracy
    public let speed: CLLocationSpeed
    public let course: CLLocationDirection
    public let timestamp: Date

    public init(
        coordinate: CLLocationCoordinate2D,
        altitude: CLLocationDistance,
        horizontalAccuracy: CLLocationAccuracy,
        verticalAccuracy: CLLocationAccuracy,
        speed: CLLocationSpeed,
        course: CLLocationDirection,
        timestamp: Date
    ) {
        self.coordinate = coordinate
        self.altitude = altitude
        self.horizontalAccuracy = horizontalAccuracy
        self.verticalAccuracy = verticalAccuracy
        self.speed = speed
        self.course = course
        self.timestamp = timestamp
    }

    init(_ location: CLLocation) {
        self.coordinate = location.coordinate
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.speed = location.speed
        self.course = location.course
        self.timestamp = location.timestamp
    }
}

extension RawLocation: Equatable {
    public static func == (lhs: RawLocation, rhs: RawLocation) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude
            && lhs.coordinate.longitude == rhs.coordinate.longitude
            && lhs.altitude == rhs.altitude
            && lhs.horizontalAccuracy == rhs.horizontalAccuracy
            && lhs.verticalAccuracy == rhs.verticalAccuracy
            && lhs.speed == rhs.speed
            && lhs.course == rhs.course
            && lhs.timestamp == rhs.timestamp
    }
}

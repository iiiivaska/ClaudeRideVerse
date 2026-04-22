import CoreLocation

/// Configuration for a GPS recording session.
public struct RecordingConfiguration: Sendable, Equatable {
    public var activityType: CLActivityType
    public var pausesAutomatically: Bool

    public init(
        activityType: CLActivityType = .fitness,
        pausesAutomatically: Bool = false
    ) {
        self.activityType = activityType
        self.pausesAutomatically = pausesAutomatically
    }

    /// Optimised for bicycle recording.
    public static let cycling = RecordingConfiguration(
        activityType: .fitness,
        pausesAutomatically: false
    )

    /// Walking preset for future use.
    public static let walking = RecordingConfiguration(
        activityType: .fitness,
        pausesAutomatically: false
    )
}

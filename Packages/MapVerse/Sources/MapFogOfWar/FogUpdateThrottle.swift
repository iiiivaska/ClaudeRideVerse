/// Rate-limits fog GeoJSON updates to avoid overwhelming MapLibre.
///
/// When cells are added rapidly during active recording, the throttle
/// ensures the map source is refreshed at a sustainable cadence
/// (default: 1 update per second).
///
/// ```swift
/// let throttle = FogUpdateThrottle()
/// if await throttle.shouldUpdate() {
///     mapSource.setGeoJSON(fogLayer.geoJSON(...))
/// }
/// ```
public actor FogUpdateThrottle {

    private let interval: Duration
    private var lastUpdate: ContinuousClock.Instant?

    /// Creates a throttle with the given minimum interval between updates.
    ///
    /// - Parameter interval: Minimum time between updates. Defaults to 1 second.
    public init(interval: Duration = .seconds(1)) {
        self.interval = interval
    }

    /// Returns `true` if enough time has passed since the last update.
    ///
    /// Marks the current time as the last update when returning `true`.
    public func shouldUpdate() -> Bool {
        let now = ContinuousClock.now
        if let last = lastUpdate, now - last < interval {
            return false
        }
        lastUpdate = now
        return true
    }

    /// Resets the throttle, allowing the next update immediately.
    public func reset() {
        lastUpdate = nil
    }
}

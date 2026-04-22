import CoreLocation

// MARK: - Protocol

/// Abstraction over the system location provider, enabling unit tests
/// with synthetic data.
protocol LocationSource: Sendable {
    func startUpdates(
        configuration: RecordingConfiguration
    ) -> AsyncThrowingStream<RawLocation, any Error>
}

// MARK: - Production Implementation

/// Wraps `CLLocationUpdate.liveUpdates` into an `AsyncThrowingStream<RawLocation>`.
struct CLLocationUpdateSource: LocationSource, Sendable {

    func startUpdates(
        configuration: RecordingConfiguration
    ) -> AsyncThrowingStream<RawLocation, any Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    for try await update in CLLocationUpdate.liveUpdates(.fitness) {
                        if Task.isCancelled { break }

                        if update.authorizationDenied || update.authorizationDeniedGlobally {
                            continuation.finish(
                                throwing: LocationRecordingError.authorizationDenied
                            )
                            return
                        }

                        if update.locationUnavailable {
                            // Transient — the system may recover. Skip, don't fail.
                            continue
                        }

                        guard let clLocation = update.location else { continue }
                        continuation.yield(RawLocation(clLocation))
                    }
                    // Sequence ended naturally.
                    continuation.finish()
                } catch {
                    continuation.finish(
                        throwing: LocationRecordingError.interrupted
                    )
                }
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}

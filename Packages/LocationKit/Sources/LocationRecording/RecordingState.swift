/// Errors originating from the location recording pipeline.
public enum LocationRecordingError: Error, Sendable, Equatable {
    /// Location authorization was denied by the user or globally.
    case authorizationDenied
    /// The device cannot determine its location.
    case locationUnavailable
    /// The recording stream was interrupted unexpectedly.
    case interrupted
}

/// Lifecycle state of a `LocationRecorder`.
public enum RecordingState: Sendable, Equatable {
    case idle
    case recording
    case paused
    case failed(LocationRecordingError)
}

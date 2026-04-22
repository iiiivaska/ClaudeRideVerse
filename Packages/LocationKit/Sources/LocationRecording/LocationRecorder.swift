import CoreLocation

/// Async-native GPS recorder.
///
/// Wraps `CLLocationUpdate.liveUpdates(.fitness)` with pause / resume / stop
/// lifecycle. All state is actor-isolated; the public surface is `Sendable`.
///
/// - Important: This is the Phase 0 foreground-only implementation.
///   Background session support will be added in Phase 1.
public actor LocationRecorder {

    // MARK: - Public state

    /// Current lifecycle state.
    public private(set) var state: RecordingState = .idle

    // MARK: - Private state

    private let configuration: RecordingConfiguration
    private let source: any LocationSource

    private var isPaused = false
    private var updateTask: Task<Void, Never>?
    private var continuation: AsyncThrowingStream<RawLocation, any Error>.Continuation?
    private var activeStream: AsyncThrowingStream<RawLocation, any Error>?

    // MARK: - Init

    /// Creates a recorder with the given configuration.
    public init(configuration: RecordingConfiguration = .cycling) {
        self.configuration = configuration
        self.source = CLLocationUpdateSource()
    }

    /// Package-internal init for unit testing with a mock source.
    init(configuration: RecordingConfiguration = .cycling, source: any LocationSource) {
        self.configuration = configuration
        self.source = source
    }

    // MARK: - Public API

    /// Starts recording and returns an async stream of locations.
    ///
    /// Idempotent: if already recording or paused, returns the existing stream.
    /// After ``stop()`` or a failure, calling ``start()`` begins a fresh session.
    public func start() -> AsyncThrowingStream<RawLocation, any Error> {
        if state == .recording || state == .paused, let activeStream {
            return activeStream
        }

        cleanup()

        let (stream, continuation) = AsyncThrowingStream<RawLocation, any Error>.makeStream()
        self.continuation = continuation
        self.activeStream = stream

        state = .recording
        isPaused = false

        let sourceStream = source.startUpdates(configuration: configuration)

        updateTask = Task {
            do {
                for try await location in sourceStream {
                    guard !Task.isCancelled else { break }
                    if !self.isPaused {
                        self.continuation?.yield(location)
                    }
                }
                // Stream ended naturally.
                if !Task.isCancelled {
                    self.finishStream()
                }
            } catch is CancellationError {
                // Cancelled by stop() — it already handled cleanup.
                return
            } catch let error as LocationRecordingError {
                guard !Task.isCancelled else { return }
                self.failWith(error)
            } catch {
                guard !Task.isCancelled else { return }
                self.failWith(.interrupted)
            }
        }

        return stream
    }

    /// Pauses yielding locations. The underlying GPS session stays active
    /// so resume is instantaneous.
    public func pause() {
        guard state == .recording else { return }
        isPaused = true
        state = .paused
    }

    /// Resumes yielding locations after a pause.
    public func resume() {
        guard state == .paused else { return }
        isPaused = false
        state = .recording
    }

    /// Stops recording and finishes the stream.
    public func stop() {
        cleanup()
        state = .idle
    }

    // MARK: - Private helpers

    private func cleanup() {
        updateTask?.cancel()
        updateTask = nil
        continuation?.finish()
        continuation = nil
        activeStream = nil
        isPaused = false
    }

    private func finishStream() {
        continuation?.finish()
        continuation = nil
        activeStream = nil
        updateTask = nil
        if state == .recording || state == .paused {
            state = .idle
        }
    }

    private func failWith(_ error: LocationRecordingError) {
        continuation?.finish(throwing: error)
        continuation = nil
        activeStream = nil
        updateTask = nil
        state = .failed(error)
    }
}

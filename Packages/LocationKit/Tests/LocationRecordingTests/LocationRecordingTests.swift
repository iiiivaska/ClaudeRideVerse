import CoreLocation
import Testing
@testable import LocationRecording

// MARK: - Test Helpers

/// A controllable location source for unit testing.
struct MockLocationSource: LocationSource, Sendable {
    let producer: @Sendable (
        AsyncThrowingStream<RawLocation, any Error>.Continuation
    ) -> Void

    func startUpdates(
        configuration: RecordingConfiguration
    ) -> AsyncThrowingStream<RawLocation, any Error> {
        AsyncThrowingStream { continuation in
            producer(continuation)
        }
    }
}

/// A source that returns a pre-built stream, giving the test direct
/// control over the continuation for deterministic sequencing.
struct DirectMockSource: LocationSource, Sendable {
    let stream: AsyncThrowingStream<RawLocation, any Error>
    func startUpdates(
        configuration: RecordingConfiguration
    ) -> AsyncThrowingStream<RawLocation, any Error> { stream }
}

/// Creates a ``RawLocation`` with sensible defaults for testing.
func makeLocation(
    latitude: Double = 55.7558,
    longitude: Double = 37.6173,
    timestamp: Date = .now
) -> RawLocation {
    RawLocation(
        coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
        altitude: 150,
        horizontalAccuracy: 5,
        verticalAccuracy: 8,
        speed: 5.0,
        course: 90,
        timestamp: timestamp
    )
}

// MARK: - RawLocation Tests

@Suite("RawLocation")
struct RawLocationTests {

    @Test("init stores all fields")
    func initStoresAllFields() {
        let coord = CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173)
        let date = Date(timeIntervalSince1970: 1_000_000)
        let loc = RawLocation(
            coordinate: coord,
            altitude: 200,
            horizontalAccuracy: 10,
            verticalAccuracy: 15,
            speed: 8.5,
            course: 180,
            timestamp: date
        )

        #expect(loc.coordinate.latitude == 55.7558)
        #expect(loc.coordinate.longitude == 37.6173)
        #expect(loc.altitude == 200)
        #expect(loc.horizontalAccuracy == 10)
        #expect(loc.verticalAccuracy == 15)
        #expect(loc.speed == 8.5)
        #expect(loc.course == 180)
        #expect(loc.timestamp == date)
    }

    @Test("Equatable compares all fields")
    func equatableComparesAllFields() {
        let date = Date(timeIntervalSince1970: 1_000_000)
        let a = RawLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2),
            altitude: 3, horizontalAccuracy: 4, verticalAccuracy: 5,
            speed: 6, course: 7, timestamp: date
        )
        let b = a
        #expect(a == b)

        let c = RawLocation(
            coordinate: CLLocationCoordinate2D(latitude: 1, longitude: 2.0001),
            altitude: 3, horizontalAccuracy: 4, verticalAccuracy: 5,
            speed: 6, course: 7, timestamp: date
        )
        #expect(a != c)
    }

    @Test("init from CLLocation")
    func initFromCLLocation() {
        let clLoc = CLLocation(
            coordinate: CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
            altitude: 35,
            horizontalAccuracy: 10,
            verticalAccuracy: 12,
            course: 270,
            speed: 3.0,
            timestamp: Date(timeIntervalSince1970: 500_000)
        )
        let raw = RawLocation(clLoc)

        #expect(raw.coordinate.latitude == clLoc.coordinate.latitude)
        #expect(raw.coordinate.longitude == clLoc.coordinate.longitude)
        #expect(raw.altitude == clLoc.altitude)
        #expect(raw.speed == clLoc.speed)
        #expect(raw.course == clLoc.course)
    }
}

// MARK: - RecordingConfiguration Tests

@Suite("RecordingConfiguration")
struct RecordingConfigurationTests {

    @Test("cycling preset defaults")
    func cyclingPresetDefaults() {
        let config = RecordingConfiguration.cycling
        #expect(config.activityType == .fitness)
        #expect(config.pausesAutomatically == false)
    }

    @Test("walking preset defaults")
    func walkingPresetDefaults() {
        let config = RecordingConfiguration.walking
        #expect(config.activityType == .fitness)
        #expect(config.pausesAutomatically == false)
    }

    @Test("custom configuration")
    func customConfiguration() {
        let config = RecordingConfiguration(
            activityType: .otherNavigation,
            pausesAutomatically: true
        )
        #expect(config.activityType == .otherNavigation)
        #expect(config.pausesAutomatically == true)
    }

    @Test("Equatable")
    func equatable() {
        #expect(RecordingConfiguration.cycling == RecordingConfiguration.cycling)
        #expect(
            RecordingConfiguration.cycling
                != RecordingConfiguration(activityType: .fitness, pausesAutomatically: true)
        )
    }
}

// MARK: - RecordingState Tests

@Suite("RecordingState")
struct RecordingStateTests {

    @Test("all cases are Equatable")
    func allCasesEquatable() {
        #expect(RecordingState.idle == .idle)
        #expect(RecordingState.recording == .recording)
        #expect(RecordingState.paused == .paused)
        #expect(RecordingState.failed(.authorizationDenied) == .failed(.authorizationDenied))
        #expect(RecordingState.failed(.authorizationDenied) != .failed(.interrupted))
        #expect(RecordingState.idle != .recording)
    }

    @Test("error cases are distinct")
    func errorCasesDistinct() {
        let errors: [LocationRecordingError] = [
            .authorizationDenied, .locationUnavailable, .interrupted,
        ]
        for (i, a) in errors.enumerated() {
            for (j, b) in errors.enumerated() {
                if i == j {
                    #expect(a == b)
                } else {
                    #expect(a != b)
                }
            }
        }
    }
}

// MARK: - LocationRecorder Tests

@Suite("LocationRecorder")
struct LocationRecorderTests {

    @Test("initial state is idle")
    func initialStateIsIdle() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { $0.finish() }
        )
        let state = await recorder.state
        #expect(state == .idle)
    }

    @Test("start transitions to recording")
    func startTransitionsToRecording() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in
                // Never finish — keeps the stream alive.
            }
        )
        _ = await recorder.start()
        let state = await recorder.state
        #expect(state == .recording)
    }

    @Test("pause transitions to paused")
    func pauseTransitionsToPaused() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in }
        )
        _ = await recorder.start()
        await recorder.pause()
        let state = await recorder.state
        #expect(state == .paused)
    }

    @Test("resume transitions back to recording")
    func resumeTransitionsToRecording() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in }
        )
        _ = await recorder.start()
        await recorder.pause()
        await recorder.resume()
        let state = await recorder.state
        #expect(state == .recording)
    }

    @Test("stop transitions to idle")
    func stopTransitionsToIdle() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in }
        )
        _ = await recorder.start()
        await recorder.stop()
        let state = await recorder.state
        #expect(state == .idle)
    }

    @Test("stop from paused transitions to idle")
    func stopFromPausedTransitionsToIdle() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in }
        )
        _ = await recorder.start()
        await recorder.pause()
        await recorder.stop()
        let state = await recorder.state
        #expect(state == .idle)
    }

    @Test("pause is no-op when idle")
    func pauseNoOpWhenIdle() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { $0.finish() }
        )
        await recorder.pause()
        let state = await recorder.state
        #expect(state == .idle)
    }

    @Test("resume is no-op when idle")
    func resumeNoOpWhenIdle() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { $0.finish() }
        )
        await recorder.resume()
        let state = await recorder.state
        #expect(state == .idle)
    }

    @Test("locations flow through the stream")
    func locationsFlowThroughStream() async throws {
        let locations = [
            makeLocation(latitude: 1, longitude: 2),
            makeLocation(latitude: 3, longitude: 4),
            makeLocation(latitude: 5, longitude: 6),
        ]

        let recorder = LocationRecorder(
            source: MockLocationSource { continuation in
                for loc in locations {
                    continuation.yield(loc)
                }
                continuation.finish()
            }
        )

        let stream = await recorder.start()
        var received: [RawLocation] = []
        for try await loc in stream {
            received.append(loc)
        }

        #expect(received == locations)
    }

    @Test("paused locations are skipped")
    func pausedLocationsAreSkipped() async throws {
        let loc1 = makeLocation(latitude: 1, longitude: 1)
        let pausedLoc = makeLocation(latitude: 2, longitude: 2)
        let resumedLoc = makeLocation(latitude: 3, longitude: 3)

        // Use DirectMockSource so the test controls exactly when
        // locations arrive via the continuation — no timing races.
        let (sourceStream, sourceCont) = AsyncThrowingStream<RawLocation, any Error>.makeStream()
        let recorder = LocationRecorder(
            source: DirectMockSource(stream: sourceStream)
        )

        let outputStream = await recorder.start()

        // 1. Yield before pause — should pass through.
        sourceCont.yield(loc1)
        try await Task.sleep(for: .milliseconds(30))

        // 2. Pause, then yield — should be skipped.
        await recorder.pause()
        sourceCont.yield(pausedLoc)
        try await Task.sleep(for: .milliseconds(30))

        // 3. Resume, then yield — should pass through.
        await recorder.resume()
        sourceCont.yield(resumedLoc)
        try await Task.sleep(for: .milliseconds(30))

        // 4. Finish the source so the output stream ends.
        sourceCont.finish()

        // Collect everything that made it through.
        var received: [RawLocation] = []
        for try await loc in outputStream {
            received.append(loc)
        }

        #expect(received.contains(loc1))
        #expect(!received.contains(pausedLoc))
        #expect(received.contains(resumedLoc))
    }

    @Test("error propagates to stream and state")
    func errorPropagatesToStreamAndState() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { continuation in
                continuation.finish(throwing: LocationRecordingError.authorizationDenied)
            }
        )

        let stream = await recorder.start()
        var receivedError: LocationRecordingError?

        do {
            for try await _ in stream {
                // Should not receive any locations.
            }
        } catch let error as LocationRecordingError {
            receivedError = error
        } catch {
            // Unexpected error type.
        }

        #expect(receivedError == .authorizationDenied)

        // Give the actor time to process the error state.
        try? await Task.sleep(for: .milliseconds(50))
        let state = await recorder.state
        #expect(state == .failed(.authorizationDenied))
    }

    @Test("idempotent start while recording keeps same state")
    func idempotentStartKeepsSameState() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in
                // Keep stream alive.
            }
        )

        _ = await recorder.start()
        let stateAfterFirst = await recorder.state
        #expect(stateAfterFirst == .recording)

        // Second start should be no-op — still recording.
        _ = await recorder.start()
        let stateAfterSecond = await recorder.state
        #expect(stateAfterSecond == .recording)

        await recorder.stop()
    }

    @Test("start after stop begins fresh session")
    func startAfterStopBeginsFresh() async {
        let recorder = LocationRecorder(
            source: MockLocationSource { _ in }
        )

        _ = await recorder.start()
        #expect(await recorder.state == .recording)

        await recorder.stop()
        #expect(await recorder.state == .idle)

        // Fresh start after stop.
        _ = await recorder.start()
        #expect(await recorder.state == .recording)

        await recorder.stop()
    }

    @Test("stop finishes the stream")
    func stopFinishesStream() async throws {
        let recorder = LocationRecorder(
            source: MockLocationSource { continuation in
                Task {
                    // Yield forever until cancelled.
                    while !Task.isCancelled {
                        continuation.yield(makeLocation())
                        try? await Task.sleep(for: .milliseconds(20))
                    }
                }
            }
        )

        let stream = await recorder.start()
        var count = 0

        Task {
            try? await Task.sleep(for: .milliseconds(100))
            await recorder.stop()
        }

        for try await _ in stream {
            count += 1
        }

        // We should have received some locations before stop.
        #expect(count > 0)
        let state = await recorder.state
        #expect(state == .idle)
    }

    @Test("version is set")
    func versionIsSet() {
        #expect(LocationRecording.version == "1.0.0")
    }
}

#if canImport(UIKit)
import CoreLocation
import HexCore
import HexGeometry
import LocationRecording
import MapCore
import MapFogOfWar
@preconcurrency import MapLibre
import Observation

/// Manages the prototype's recording session, hex cell accumulation,
/// and fog-of-war GeoJSON generation.
///
/// Implicitly `@MainActor` via project-wide `SWIFT_DEFAULT_ACTOR_ISOLATION`.
@Observable
final class PrototypeViewModel {

    // MARK: - Published State

    var camera = MapCamera(center: CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173), zoom: 13)
    var visitedCells = HexCellSet()
    var hexCount = 0
    var recordingState: RecordingState = .idle
    var isTracking = false
    var lastLocation: CLLocationCoordinate2D?
    var fogFeatures: [MLNPolygonFeature]?
    var elapsedSeconds: Int = 0

    /// Actual visible map bounds reported by MapLibre.
    var visibleBBox: MapBBox?

    // MARK: - Private

    private var recorder: LocationRecorder?
    private var recordingTask: Task<Void, Never>?
    private var timerTask: Task<Void, Never>?
    private var fogRebuildTask: Task<Void, Never>?
    private var startDate: Date?

    // MARK: - Actions

    func startRecording() {
        guard recordingState == .idle else { return }

        let newRecorder = LocationRecorder(configuration: .cycling)
        recorder = newRecorder
        recordingState = .recording
        isTracking = true
        startDate = Date()

        // Generate initial hex grid
        handleVisibleBoundsChange()

        // Start elapsed time counter
        timerTask = Task { [weak self] in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(1))
                guard let self, !Task.isCancelled else { return }
                if let start = self.startDate {
                    self.elapsedSeconds = Int(Date().timeIntervalSince(start))
                }
            }
        }

        // Consume location stream
        recordingTask = Task { [weak self] in
            let stream = await newRecorder.start()

            do {
                for try await location in stream {
                    guard let self, !Task.isCancelled else { return }
                    self.handleLocation(location)
                }
            } catch {
                guard let self else { return }
                self.recordingState = .idle
            }
        }
    }

    func stopRecording() {
        recordingTask?.cancel()
        recordingTask = nil
        timerTask?.cancel()
        timerTask = nil

        Task {
            await recorder?.stop()
            recorder = nil
        }

        recordingState = .idle
        isTracking = false
        startDate = nil
    }

    func recenter() {
        guard let location = lastLocation else { return }
        isTracking = true
        camera = MapCamera(center: location, zoom: camera.zoom, bearing: camera.bearing, pitch: camera.pitch)
    }

    /// Called by the view when the user pans the map.
    func userDidPan() {
        if recordingState == .recording {
            isTracking = false
        }
    }

    /// Schedules a fog rebuild for the latest visible bounds.
    ///
    /// A short debounce coalesces bursts (e.g. simultaneous location update +
    /// camera change) without adding perceptible latency. The rebuild itself
    /// is cheap enough that we don't try to short-circuit it; the new
    /// `coverViewport` always covers the visible area, so deciding *not* to
    /// rebuild would only ever leave the user with stale fog.
    func handleVisibleBoundsChange() {
        guard visibleBBox != nil else { return }

        fogRebuildTask?.cancel()
        fogRebuildTask = Task {
            try? await Task.sleep(for: .milliseconds(50))
            guard !Task.isCancelled else { return }
            await regenerateFog()
        }
    }

    // MARK: - Private Helpers

    private func handleLocation(_ location: RawLocation) {
        lastLocation = location.coordinate

        guard let cell = try? HexCell(coordinate: location.coordinate, resolution: .r10) else { return }

        let isNew = visitedCells.insert(cell)
        if isNew {
            hexCount = visitedCells.count
            // Force rebuild — new cell needs to be shown as explored.
            handleVisibleBoundsChange()
        }

        if isTracking {
            camera = MapCamera(
                center: location.coordinate,
                zoom: camera.zoom,
                bearing: camera.bearing,
                pitch: camera.pitch
            )
        }
    }

    private func regenerateFog() async {
        guard let bbox = visibleBBox else { return }

        let zoom = camera.zoom
        let cells = visitedCells

        // Small buffer (~15% on each side) keeps a thin pre-cache around the
        // viewport for short pans without inflating the workload at low zoom.
        let buffered = bbox.expanded(by: 0.15)

        // Heavy computation off MainActor.
        let features = await Task.detached(priority: .userInitiated) {
            HexGridBuilder.buildFeatures(
                in: buffered,
                atZoom: zoom,
                visited: cells,
                storageResolution: .r10
            )
        }.value

        guard !Task.isCancelled else { return }
        fogFeatures = features
    }
}
#endif

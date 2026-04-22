#if canImport(UIKit)
import DesignSystem
import MapCore
import SwiftUI
@preconcurrency import MapLibre

/// Custom ``UIViewRepresentable`` wrapping MLNMapView with fog-of-war rendering.
///
/// Handles two-way camera binding and pushes fog GeoJSON into an
/// ``MLNShapeSource`` + ``MLNFillStyleLayer`` once the style loads.
/// Based on ``MapViewRepresentable`` camera pattern from MapCore.
struct PrototypeMapView: UIViewRepresentable {

    @Binding var camera: MapCamera
    @Binding var visibleBBox: MapBBox?
    @Binding var userLocation: CLLocationCoordinate2D?
    let style: MapStyle
    let fogFeatures: [MLNPolygonFeature]?
    let trackCoordinates: [CLLocationCoordinate2D]
    let isTracking: Bool
    let onUserGesture: () -> Void

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero, styleURL: style.url)
        mapView.delegate = context.coordinator
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true

        applyCamera(camera, to: mapView, animated: false)
        context.coordinator.lastSyncedCamera = camera
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self

        coordinator.isUpdatingFromBinding = true
        defer { coordinator.isUpdatingFromBinding = false }

        if mapView.styleURL != style.url {
            mapView.styleURL = style.url
        }

        // Apply camera only when SwiftUI's camera value differs from the last
        // value we synchronised with the map. If they match, this update was
        // triggered by our own delegate-driven binding push and re-applying
        // would snap the user's in-progress gesture back to a stale value.
        if camera != coordinator.lastSyncedCamera {
            applyCamera(camera, to: mapView, animated: true)
            coordinator.lastSyncedCamera = camera
        }

        // Update fog source when GeoJSON changes
        if coordinator.isStyleLoaded {
            coordinator.updateFog(on: mapView, features: fogFeatures)
            coordinator.updateTrack(on: mapView, coordinates: trackCoordinates)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    // MARK: - Camera Helpers

    private func applyCamera(_ camera: MapCamera, to mapView: MLNMapView, animated: Bool) {
        let mlnCamera = MLNMapCamera(
            lookingAtCenter: camera.center,
            altitude: MLNAltitudeForZoomLevel(camera.zoom, camera.pitch, camera.center.latitude, .zero),
            pitch: camera.pitch,
            heading: camera.bearing
        )
        mapView.setCamera(mlnCamera, animated: animated)
        mapView.zoomLevel = camera.zoom
    }
}

// MARK: - Coordinator

extension PrototypeMapView {
    @MainActor
    final class Coordinator: NSObject, MLNMapViewDelegate {
        /// Refreshed from `updateUIView` so the stored snapshot matches the
        /// latest SwiftUI-provided struct (and its `onUserGesture` closure).
        var parent: PrototypeMapView

        var isUpdatingFromBinding = false
        var isStyleLoaded = false
        var hasInitiallyCentered = false

        /// Snapshot of the camera value that the delegate last pushed into the
        /// SwiftUI binding. `updateUIView` compares against this to decide
        /// whether `applyCamera` needs to run — when SwiftUI's camera matches
        /// what we just pushed, the update is our own echo and re-applying
        /// would fight the user's gesture.
        var lastSyncedCamera: MapCamera?

        private static let fogSourceID = "fog-source"
        private static let fogLayerID = "fog-layer"
        private static let trackSourceID = "track-source"
        private static let trackHaloLayerID = "track-halo"
        private static let trackLineLayerID = "track-line"
        private static let startMarkerSourceID = "start-marker-source"
        private static let startMarkerLayerID = "start-marker-layer"

        /// Wall-clock throttle for live-region updates. ~30 Hz is well below
        /// MLNMapView's 60 Hz pan/zoom cadence and unnoticeable visually,
        /// while keeping SwiftUI invalidation pressure bounded.
        private static let liveUpdateThrottleInterval: TimeInterval = 0.033
        private var lastLiveUpdateAt: Date = .distantPast

        init(parent: PrototypeMapView) {
            self.parent = parent
        }

        // MARK: Style Load

        nonisolated func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            MainActor.assumeIsolated {
                isStyleLoaded = true
                installTrackLayers(on: mapView, style: style)
                installHexGrid(on: mapView, style: style)
                updateFog(on: mapView, features: parent.fogFeatures)
                updateTrack(on: mapView, coordinates: parent.trackCoordinates)
            }
        }

        // MARK: Initial Location Centering

        nonisolated func mapView(_ mapView: MLNMapView, didUpdate userLocation: MLNUserLocation?) {
            guard let coord = userLocation?.coordinate,
                  CLLocationCoordinate2DIsValid(coord)
            else { return }

            let lat = coord.latitude
            let lon = coord.longitude

            MainActor.assumeIsolated {
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                parent.userLocation = coordinate

                // Follow user during tracking (sticky mode)
                if parent.isTracking {
                    let newCamera = MapCamera(
                        center: coordinate,
                        zoom: parent.camera.zoom,
                        bearing: parent.camera.bearing,
                        pitch: parent.camera.pitch
                    )
                    parent.camera = newCamera
                    lastSyncedCamera = newCamera
                    return
                }

                // Initial centering on first fix
                guard !hasInitiallyCentered else { return }
                hasInitiallyCentered = true
                let newCamera = MapCamera(
                    center: coordinate,
                    zoom: parent.camera.zoom,
                    bearing: parent.camera.bearing,
                    pitch: parent.camera.pitch
                )
                parent.camera = newCamera
                lastSyncedCamera = newCamera
            }
        }

        // MARK: Camera Sync

        /// Detect user gestures so the view model can exit auto-follow mode.
        /// Without this, `PrototypeViewModel.handleLocation` would keep writing
        /// `camera = GPS location` every GPS tick and fight the user's zoom/pan.
        nonisolated func mapView(
            _ mapView: MLNMapView,
            regionWillChangeWith reason: MLNCameraChangeReason,
            animated: Bool
        ) {
            MainActor.assumeIsolated {
                let userGestures: MLNCameraChangeReason = [
                    .gesturePan,
                    .gesturePinch,
                    .gestureRotate,
                    .gestureZoomIn,
                    .gestureZoomOut,
                    .gestureOneFingerZoom,
                    .gestureTilt,
                ]
                if !reason.intersection(userGestures).isEmpty {
                    parent.onUserGesture()
                }
            }
        }

        /// Live updates during a pan/pinch gesture — throttled to ~30 Hz so we
        /// don't flood the SwiftUI view-update cycle on every render frame.
        nonisolated func mapViewRegionIsChanging(_ mapView: MLNMapView) {
            MainActor.assumeIsolated {
                let now = Date()
                guard now.timeIntervalSince(lastLiveUpdateAt) >= Self.liveUpdateThrottleInterval else {
                    return
                }
                lastLiveUpdateAt = now
                pushCameraAndBBox(from: mapView)
            }
        }

        /// Final-frame update — fired once when the gesture/animation ends.
        nonisolated func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
            MainActor.assumeIsolated {
                lastLiveUpdateAt = Date()
                pushCameraAndBBox(from: mapView)
            }
        }

        private func pushCameraAndBBox(from mapView: MLNMapView) {
            guard !isUpdatingFromBinding else { return }

            let newCamera = MapCamera(
                center: mapView.centerCoordinate,
                zoom: mapView.zoomLevel,
                bearing: mapView.direction,
                pitch: mapView.camera.pitch
            )

            let bounds = mapView.visibleCoordinateBounds
            let newBBox = MapBBox(
                northEast: CLLocationCoordinate2D(
                    latitude: bounds.ne.latitude,
                    longitude: bounds.ne.longitude
                ),
                southWest: CLLocationCoordinate2D(
                    latitude: bounds.sw.latitude,
                    longitude: bounds.sw.longitude
                )
            )

            // Atomic on MainActor: update `parent.camera`, `parent.visibleBBox`
            // and `lastSyncedCamera` together so that when SwiftUI re-evaluates
            // and `updateUIView` runs, `camera == lastSyncedCamera` and the
            // redundant `applyCamera` is skipped — leaving the user's gesture
            // uninterrupted.
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.parent.visibleBBox = newBBox
                if newCamera != self.parent.camera {
                    self.parent.camera = newCamera
                }
                self.lastSyncedCamera = newCamera
            }
        }

        // MARK: Hex Grid Rendering

        private func installHexGrid(on mapView: MLNMapView, style: MLNStyle) {
            guard style.source(withIdentifier: Self.fogSourceID) == nil else { return }

            let source = MLNShapeSource(
                identifier: Self.fogSourceID,
                shape: nil,
                options: nil
            )
            style.addSource(source)

            // Fill layer: data-driven color based on "s" property.
            // s=0 (unexplored): dark fog    s=1 (explored): blue tint
            let fill = MLNFillStyleLayer(identifier: Self.fogLayerID, source: source)
            fill.fillColor = NSExpression(
                forMLNInterpolating: NSExpression(forKeyPath: "s"),
                curveType: .linear,
                parameters: nil,
                stops: NSExpression(forConstantValue: [
                    0: UIColor.fogHexUnexplored,
                    1: UIColor.fogHexExplored,
                ])
            )
            fill.fillOpacity = NSExpression(forConstantValue: 1.0)
            style.addLayer(fill)

            // Line layer: subtle hex grid borders for all cells.
            let line = MLNLineStyleLayer(identifier: "hex-grid-line", source: source)
            line.lineColor = NSExpression(forConstantValue: UIColor.fogHexGridLine)
            line.lineWidth = NSExpression(forConstantValue: 0.5)
            style.addLayer(line)
        }

        func updateFog(on mapView: MLNMapView, features: [MLNPolygonFeature]?) {
            guard let style = mapView.style,
                  let source = style.source(withIdentifier: Self.fogSourceID) as? MLNShapeSource
            else { return }

            guard let features, !features.isEmpty else {
                source.shape = nil
                return
            }

            let collection = MLNShapeCollectionFeature(shapes: features)
            source.shape = collection
        }

        // MARK: Track Rendering

        private func installTrackLayers(on mapView: MLNMapView, style: MLNStyle) {
            guard style.source(withIdentifier: Self.trackSourceID) == nil else { return }

            // Track polyline source
            let trackSource = MLNShapeSource(identifier: Self.trackSourceID, shape: nil, options: nil)
            style.addSource(trackSource)

            // Halo layer — wider, semi-transparent accent
            let halo = MLNLineStyleLayer(identifier: Self.trackHaloLayerID, source: trackSource)
            halo.lineColor = NSExpression(forConstantValue: UIColor(red: 10 / 255, green: 132 / 255, blue: 255 / 255, alpha: 0.44))
            halo.lineWidth = NSExpression(forConstantValue: 7)
            halo.lineCap = NSExpression(forConstantValue: "round")
            halo.lineJoin = NSExpression(forConstantValue: "round")
            style.addLayer(halo)

            // Core line — thin, full-opacity accent
            let core = MLNLineStyleLayer(identifier: Self.trackLineLayerID, source: trackSource)
            core.lineColor = NSExpression(forConstantValue: UIColor(red: 10 / 255, green: 132 / 255, blue: 255 / 255, alpha: 1.0))
            core.lineWidth = NSExpression(forConstantValue: 2.5)
            core.lineCap = NSExpression(forConstantValue: "round")
            core.lineJoin = NSExpression(forConstantValue: "round")
            style.addLayer(core)

            // Start marker source
            let markerSource = MLNShapeSource(identifier: Self.startMarkerSourceID, shape: nil, options: nil)
            style.addSource(markerSource)

            let marker = MLNCircleStyleLayer(identifier: Self.startMarkerLayerID, source: markerSource)
            marker.circleColor = NSExpression(forConstantValue: UIColor(red: 48 / 255, green: 209 / 255, blue: 88 / 255, alpha: 1.0))
            marker.circleRadius = NSExpression(forConstantValue: 5)
            marker.circleStrokeColor = NSExpression(forConstantValue: UIColor.white)
            marker.circleStrokeWidth = NSExpression(forConstantValue: 1.5)
            style.addLayer(marker)
        }

        func updateTrack(on mapView: MLNMapView, coordinates: [CLLocationCoordinate2D]) {
            guard let style = mapView.style else { return }

            // Update track polyline
            if let trackSource = style.source(withIdentifier: Self.trackSourceID) as? MLNShapeSource {
                if coordinates.count >= 2 {
                    var coords = coordinates
                    let polyline = MLNPolylineFeature(coordinates: &coords, count: UInt(coords.count))
                    trackSource.shape = polyline
                } else {
                    trackSource.shape = nil
                }
            }

            // Update start marker
            if let markerSource = style.source(withIdentifier: Self.startMarkerSourceID) as? MLNShapeSource {
                if let first = coordinates.first {
                    let point = MLNPointFeature()
                    point.coordinate = first
                    markerSource.shape = point
                } else {
                    markerSource.shape = nil
                }
            }
        }
    }
}
#endif

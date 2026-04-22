#if canImport(UIKit)
import SwiftUI
@preconcurrency import MapLibre

/// UIViewRepresentable bridge between SwiftUI and MapLibre's `MLNMapView`.
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var camera: MapCamera
    let style: MapStyle

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero, styleURL: style.url)
        mapView.delegate = context.coordinator
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true

        applyCamera(camera, to: mapView, animated: false)
        return mapView
    }

    func updateUIView(_ mapView: MLNMapView, context: Context) {
        let coordinator = context.coordinator
        guard !coordinator.isUpdatingFromDelegate else { return }

        coordinator.isUpdatingFromBinding = true
        defer { coordinator.isUpdatingFromBinding = false }

        if mapView.styleURL != style.url {
            mapView.styleURL = style.url
        }

        applyCamera(camera, to: mapView, animated: true)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    private func applyCamera(_ camera: MapCamera, to mapView: MLNMapView, animated: Bool) {
        let mlnCamera = MLNMapCamera(
            lookingAtCenter: camera.center,
            altitude: altitudeForZoom(camera.zoom, pitch: camera.pitch, latitude: camera.center.latitude),
            pitch: camera.pitch,
            heading: camera.bearing
        )
        mapView.setCamera(mlnCamera, animated: animated)
        mapView.zoomLevel = camera.zoom
    }

    /// Converts a Web Mercator zoom level to MapLibre camera altitude.
    private func altitudeForZoom(_ zoom: Double, pitch: Double, latitude: Double) -> CLLocationDistance {
        // MapLibre provides this conversion
        MLNAltitudeForZoomLevel(zoom, pitch, latitude, .zero)
    }
}

// MARK: - Coordinator

extension MapViewRepresentable {
    @MainActor
    final class Coordinator: NSObject, MLNMapViewDelegate {
        private let parent: MapViewRepresentable

        var isUpdatingFromBinding = false
        var isUpdatingFromDelegate = false

        init(parent: MapViewRepresentable) {
            self.parent = parent
        }

        nonisolated func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
            MainActor.assumeIsolated {
                guard !isUpdatingFromBinding else { return }

                isUpdatingFromDelegate = true
                defer { isUpdatingFromDelegate = false }

                let newCamera = MapCamera(
                    center: mapView.centerCoordinate,
                    zoom: mapView.zoomLevel,
                    bearing: mapView.direction,
                    pitch: mapView.camera.pitch
                )

                if newCamera != parent.camera {
                    parent.camera = newCamera
                }
            }
        }
    }
}
#endif

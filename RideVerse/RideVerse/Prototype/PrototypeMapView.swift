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
    let style: MapStyle
    let fogFeatures: [MLNPolygonFeature]?

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> MLNMapView {
        let mapView = MLNMapView(frame: .zero, styleURL: style.url)
        mapView.delegate = context.coordinator
        mapView.logoView.isHidden = true
        mapView.attributionButton.isHidden = true
        mapView.showsUserLocation = true

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

        // Update fog source when GeoJSON changes
        if coordinator.isStyleLoaded {
            coordinator.updateFog(on: mapView, features: fogFeatures)
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
        private let parent: PrototypeMapView

        var isUpdatingFromBinding = false
        var isUpdatingFromDelegate = false
        var isStyleLoaded = false

        private static let fogSourceID = "fog-source"
        private static let fogLayerID = "fog-layer"

        init(parent: PrototypeMapView) {
            self.parent = parent
        }

        // MARK: Style Load

        nonisolated func mapView(_ mapView: MLNMapView, didFinishLoading style: MLNStyle) {
            MainActor.assumeIsolated {
                isStyleLoaded = true
                installHexGrid(on: mapView, style: style)
                updateFog(on: mapView, features: parent.fogFeatures)
            }
        }

        // MARK: Camera Sync

        nonisolated func mapView(_ mapView: MLNMapView, regionDidChangeAnimated animated: Bool) {
            MainActor.assumeIsolated {
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

                // Defer binding updates to avoid modifying state during view update.
                Task { @MainActor [weak self] in
                    guard let self else { return }
                    self.isUpdatingFromDelegate = true
                    self.parent.visibleBBox = newBBox
                    if newCamera != self.parent.camera {
                        self.parent.camera = newCamera
                    }
                    self.isUpdatingFromDelegate = false
                }
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
    }
}
#endif

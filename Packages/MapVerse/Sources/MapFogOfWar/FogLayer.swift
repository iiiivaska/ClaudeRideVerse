import Foundation
import HexCore
import HexGeometry
import MapCore

/// A map content layer that renders fog-of-war via inverted multipolygon.
///
/// `FogLayer` conforms to ``MapContent`` for declarative composition
/// inside a ``MapView``. Call ``geoJSON(in:atZoom:)`` to produce
/// the GeoJSON data that a MapLibre `MLNShapeSource` consumes.
///
/// ```swift
/// MapView(camera: $camera, style: .demotiles) {
///     FogLayer(visited: myAdapter, style: .default)
/// }
/// ```
public struct FogLayer: MapContent {

    /// The source of visited cell data.
    public let visited: any VisitedCells

    /// Visual styling for the fog overlay.
    public let style: FogStyle

    public init(visited: any VisitedCells, style: FogStyle = .default) {
        self.visited = visited
        self.style = style
    }

    /// Generates GeoJSON data for the fog at the given viewport and zoom level.
    ///
    /// The result is a GeoJSON Feature with an inverted MultiPolygon:
    /// the world is covered with fog, and visited hex cells are holes.
    ///
    /// - Parameters:
    ///   - bbox: The visible map bounding box.
    ///   - zoom: The current map zoom level (determines detail via ``FogResolutionPolicy``).
    /// - Returns: GeoJSON data suitable for a MapLibre `MLNShapeSource`.
    public func geoJSON(in bbox: MapBBox, atZoom zoom: Double) -> Data {
        let cellSet = visited.cellSet(in: bbox, atZoom: zoom)

        guard !cellSet.isEmpty else {
            return FogGeoJSONBuilder.buildEmptyFogGeoJSON()
        }

        let multiPolygon = cellSet.multiPolygon()
        return FogGeoJSONBuilder.buildGeoJSON(from: multiPolygon)
    }
}

import CoreLocation
import Foundation
import HexCore

/// Builds inverted MultiPolygon GeoJSON for fog-of-war rendering.
///
/// The fog covers the entire visible world. Visited hex cell boundaries
/// become holes in the fog polygon, revealing the map underneath.
/// Any inner holes within visited polygon groups become re-fog patches
/// (areas surrounded by visited cells but not visited themselves).
public enum FogGeoJSONBuilder: Sendable {

    /// World-spanning exterior ring (counter-clockwise per RFC 7946).
    /// Latitude clamped to the Web Mercator limit (~85.051129 degrees).
    private static let worldExteriorRing: [[Double]] = [
        [-180, -85.051129],
        [-180,  85.051129],
        [ 180,  85.051129],
        [ 180, -85.051129],
        [-180, -85.051129],
    ]

    // MARK: - Public API

    /// Builds GeoJSON data for the inverted fog polygon.
    ///
    /// The result is a GeoJSON Feature with MultiPolygon geometry:
    /// - First polygon: world exterior with visited area outer rings as holes
    /// - Additional polygons: re-fog patches for inner holes in visited groups
    ///
    /// For empty input, returns a full-coverage fog (``Polygon`` with no holes).
    public static func buildGeoJSON(from multiPolygon: HexMultiPolygon) -> Data {
        guard !multiPolygon.isEmpty else {
            return buildEmptyFogGeoJSON()
        }

        // Main fog polygon: world exterior + visited outers as holes
        var mainRings: [[[Double]]] = [worldExteriorRing]
        var refogPatches: [[[[Double]]]] = []

        for polygon in multiPolygon.polygons {
            let outerRing = polygon.outer.map { [$0.longitude, $0.latitude] }
            mainRings.append(outerRing)

            // Inner holes in visited polygons become re-fog patches
            for hole in polygon.holes {
                let holeRing = hole.map { [$0.longitude, $0.latitude] }
                refogPatches.append([holeRing])
            }
        }

        var coordinates: [[[[Double]]]] = [mainRings]
        coordinates.append(contentsOf: refogPatches)

        let geoJSON: [String: Any] = [
            "type": "Feature",
            "geometry": [
                "type": "MultiPolygon",
                "coordinates": coordinates,
            ] as [String: Any],
        ]

        // Structure is guaranteed serializable (arrays of doubles/strings only)
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: geoJSON)
    }

    /// Builds GeoJSON for complete fog coverage (no visited cells).
    public static func buildEmptyFogGeoJSON() -> Data {
        let geoJSON: [String: Any] = [
            "type": "Feature",
            "geometry": [
                "type": "Polygon",
                "coordinates": [worldExteriorRing],
            ] as [String: Any],
        ]
        // swiftlint:disable:next force_try
        return try! JSONSerialization.data(withJSONObject: geoJSON)
    }
}

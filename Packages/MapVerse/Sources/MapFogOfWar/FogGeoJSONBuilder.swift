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
            // Outer rings become holes in the fog — must be CW and closed.
            let outerRing = closedRing(polygon.outer.map { [$0.longitude, $0.latitude] }, clockwise: true)
            mainRings.append(outerRing)

            // Inner holes in visited polygons become re-fog patches (CCW exterior).
            for hole in polygon.holes {
                let holeRing = closedRing(hole.map { [$0.longitude, $0.latitude] }, clockwise: false)
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

        // Structure is expected to be serializable (arrays of doubles/strings only).
        // On the pathological case (NaN in coords, OOM, etc.) fall back to a
        // full-coverage fog so the map still renders without crashing.
        guard let data = try? JSONSerialization.data(withJSONObject: geoJSON) else {
            return buildEmptyFogGeoJSON()
        }
        return data
    }

    // MARK: - Ring Helpers

    /// Ensures the ring is closed (first == last) and wound in the requested direction.
    private static func closedRing(_ ring: [[Double]], clockwise: Bool) -> [[Double]] {
        guard ring.count >= 3 else { return ring }

        // Close if needed
        var closed = ring
        if closed.first != closed.last {
            closed.append(closed[0])
        }

        // Check winding via shoelace signed area
        let isCW = signedArea(closed) < 0
        if isCW != clockwise {
            closed.reverse()
        }

        return closed
    }

    /// Shoelace signed area. Positive = CCW, negative = CW (in lon/lat space).
    private static func signedArea(_ ring: [[Double]]) -> Double {
        var area = 0.0
        let count = ring.count
        for i in 0 ..< count {
            let j = (i + 1) % count
            // ring[i] = [lon, lat]
            area += ring[i][0] * ring[j][1]
            area -= ring[j][0] * ring[i][1]
        }
        return area / 2.0
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
        // Ultimate fallback if even this tiny object fails to serialize —
        // an empty FeatureCollection keeps the MapLibre source valid.
        return (try? JSONSerialization.data(withJSONObject: geoJSON))
            ?? Data(#"{"type":"FeatureCollection","features":[]}"#.utf8)
    }
}

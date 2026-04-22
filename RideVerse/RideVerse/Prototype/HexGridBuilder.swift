#if canImport(UIKit)
import CoreLocation
import HexCore
import HexGeometry
import MapCore
import MapFogOfWar
@preconcurrency import MapLibre

/// Generates MLNPolygonFeature arrays for the hex grid overlay.
///
/// Each cell is tagged with `"s": 0/1` for data-driven MapLibre styling.
/// Builds native MapLibre objects directly — no JSON roundtrip.
nonisolated enum HexGridBuilder {

    // MARK: - Public API

    /// Builds an array of polygon features covering the viewport.
    ///
    /// - Parameters:
    ///   - bbox: Visible map bounding box (should be pre-expanded with buffer).
    ///   - zoom: Current camera zoom level.
    ///   - visited: Set of visited cells at the finest resolution.
    ///   - storageResolution: Resolution at which cells are stored.
    /// - Returns: Array of `MLNPolygonFeature` ready for `MLNShapeCollectionFeature`.
    static func buildFeatures(
        in bbox: MapBBox,
        atZoom zoom: Double,
        visited: HexCellSet,
        storageResolution: HexResolution = .r10
    ) -> [MLNPolygonFeature] {
        let displayResolution = FogResolutionPolicy.resolution(forZoom: zoom)

        // Convert visited cells to display resolution if different from storage.
        let displayVisited: Set<UInt64>
        if displayResolution == storageResolution {
            displayVisited = Set(visited.cells.map(\.index))
        } else {
            var parents = Set<UInt64>()
            for cell in visited.cells {
                if let parent = cell.parent(at: displayResolution) {
                    parents.insert(parent.index)
                }
            }
            displayVisited = parents
        }

        // Clear boundary cache if resolution changed.
        if displayResolution != cachedResolution {
            boundaryCache.removeAll(keepingCapacity: true)
            cachedResolution = displayResolution
        }

        let viewportCells = coverViewport(bbox: bbox, resolution: displayResolution)

        var features: [MLNPolygonFeature] = []
        features.reserveCapacity(viewportCells.count)

        for cell in viewportCells {
            guard let boundary = cachedBoundary(for: cell) else { continue }

            let feature = boundary.withUnsafeBufferPointer { buf in
                MLNPolygonFeature(coordinates: buf.baseAddress!, count: UInt(buf.count))
            }
            feature.attributes = ["s": NSNumber(value: displayVisited.contains(cell.index) ? 1 : 0)]
            features.append(feature)
        }

        return features
    }

    // MARK: - Boundary Cache

    nonisolated(unsafe) private static var boundaryCache: [UInt64: [CLLocationCoordinate2D]] = [:]
    nonisolated(unsafe) private static var cachedResolution: HexResolution?

    private static func cachedBoundary(for cell: HexCell) -> [CLLocationCoordinate2D]? {
        if let cached = boundaryCache[cell.index] { return cached }
        guard let boundary = try? cell.boundary, boundary.count >= 5 else { return nil }
        // Close the ring for MapLibre polygon.
        var closed = boundary
        closed.append(boundary[0])
        boundaryCache[cell.index] = closed
        return closed
    }

    // MARK: - Viewport Cell Generation

    private static let maxCells = 5000

    private static func coverViewport(bbox: MapBBox, resolution: HexResolution) -> [HexCell] {
        let edgeMeters = resolution.averageEdgeMeters
        let latStep = (edgeMeters * 1.2) / 111_000
        let midLat = (bbox.northEast.latitude + bbox.southWest.latitude) / 2
        let lonStep = latStep / max(cos(midLat * .pi / 180), 0.01)

        var seen = Set<UInt64>()
        var cells: [HexCell] = []

        var lat = bbox.southWest.latitude
        while lat <= bbox.northEast.latitude {
            var lon = bbox.southWest.longitude
            while lon <= bbox.northEast.longitude {
                if let cell = try? HexCell(
                    coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                    resolution: resolution
                ), !seen.contains(cell.index) {
                    seen.insert(cell.index)
                    cells.append(cell)
                    if cells.count >= maxCells { return cells }
                }
                lon += lonStep
            }
            lat += latStep
        }

        return cells
    }
}
#endif

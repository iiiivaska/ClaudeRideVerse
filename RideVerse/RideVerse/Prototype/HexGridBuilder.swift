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
        let preferredResolution = FogResolutionPolicy.resolution(forZoom: zoom)
        // Drop to a coarser resolution if the viewport would exceed `maxCells`
        // at the preferred level — keeps low-zoom rebuilds bounded and full-coverage.
        let displayResolution = adjustedResolution(preferred: preferredResolution, bbox: bbox)

        // Convert visited cells to display resolution if different from storage.
        let displayVisited: Set<UInt64>
        if displayResolution == storageResolution {
            displayVisited = Set(visited.cells.map(\.index))
        } else if displayResolution < storageResolution {
            var parents = Set<UInt64>()
            for cell in visited.cells {
                if let parent = cell.parent(at: displayResolution) {
                    parents.insert(parent.index)
                }
            }
            displayVisited = parents
        } else {
            // Display finer than storage — show all r10 children of stored cells.
            var children = Set<UInt64>()
            for cell in visited.cells {
                for child in cell.children(at: displayResolution) {
                    children.insert(child.index)
                }
            }
            displayVisited = children
        }

        // Snapshot the boundary lookup under a single critical section: H3 boundary
        // computation is the slow part, but reads/writes to the shared dictionary
        // must be serialised across concurrent `Task.detached` invocations.
        let viewportCells = coverViewport(bbox: bbox, resolution: displayResolution)
        let boundaries = boundaries(for: viewportCells, resolution: displayResolution)

        var features: [MLNPolygonFeature] = []
        features.reserveCapacity(viewportCells.count)

        for cell in viewportCells {
            guard let boundary = boundaries[cell.index] else { continue }

            let feature: MLNPolygonFeature? = boundary.withUnsafeBufferPointer { buf in
                guard let addr = buf.baseAddress else { return nil }
                return MLNPolygonFeature(coordinates: addr, count: UInt(buf.count))
            }
            guard let feature else { continue }
            feature.attributes = ["s": NSNumber(value: displayVisited.contains(cell.index) ? 1 : 0)]
            features.append(feature)
        }

        return features
    }

    // MARK: - Boundary Cache

    /// Boundary cache shared across rebuilds. All access goes through `cacheLock`
    /// because `buildFeatures` runs on `Task.detached` and multiple builds can
    /// overlap in flight (the inner detached task is not cancelled when the
    /// outer rebuild task is).
    nonisolated(unsafe) private static var boundaryCache: [UInt64: [CLLocationCoordinate2D]] = [:]
    nonisolated(unsafe) private static var cachedResolution: HexResolution?
    private static let cacheLock = NSLock()

    /// Returns boundaries for the requested cells, populating the shared cache
    /// for any misses. Resolution mismatches drop the cache (the boundaries
    /// would all be wrong for the new resolution anyway).
    private static func boundaries(
        for cells: [HexCell],
        resolution: HexResolution
    ) -> [UInt64: [CLLocationCoordinate2D]] {
        // Phase 1: collect cache hits and the list of misses under the lock.
        var hits: [UInt64: [CLLocationCoordinate2D]] = [:]
        hits.reserveCapacity(cells.count)
        var misses: [HexCell] = []

        cacheLock.lock()
        if cachedResolution != resolution {
            boundaryCache.removeAll(keepingCapacity: true)
            cachedResolution = resolution
        }
        for cell in cells {
            if let cached = boundaryCache[cell.index] {
                hits[cell.index] = cached
            } else {
                misses.append(cell)
            }
        }
        cacheLock.unlock()

        guard !misses.isEmpty else { return hits }

        // Phase 2: compute misses outside the lock — H3 calls are the slow part.
        var freshlyComputed: [(UInt64, [CLLocationCoordinate2D])] = []
        freshlyComputed.reserveCapacity(misses.count)
        for cell in misses {
            guard let boundary = try? cell.boundary, boundary.count >= 5 else { continue }
            var closed = boundary
            closed.append(boundary[0])
            freshlyComputed.append((cell.index, closed))
            hits[cell.index] = closed
        }

        // Phase 3: write fresh entries back under the lock. Skip if another build
        // dropped the cache for a different resolution in between.
        cacheLock.lock()
        if cachedResolution == resolution {
            for (index, boundary) in freshlyComputed {
                boundaryCache[index] = boundary
            }
        }
        cacheLock.unlock()

        return hits
    }

    // MARK: - Viewport Cell Generation

    /// Safety cap — under normal operation the post-filter disk stays well below
    /// this. Acts as a guard against runaway `kRings` estimates near pentagons
    /// or extreme zoom.
    private static let maxCells = 5000

    /// Builds the set of cells whose centroid lies inside `bbox`, generated as
    /// a `gridDisk` around the bbox center cell.
    ///
    /// The center-out generation order means that, even when the safety cap
    /// kicks in, the visible center is always covered first.
    ///
    /// Known limitations (acceptable for the prototype):
    /// - Antimeridian: bboxes spanning ±180° longitude are not handled and
    ///   will compute a center on the wrong side of the world.
    /// - Pentagons: `gridDisk` may return fewer cells when crossing one of
    ///   the 12 pentagons at any resolution.
    private static func coverViewport(bbox: MapBBox, resolution: HexResolution) -> [HexCell] {
        let center = bbox.centerCoordinate
        guard let centerCell = try? HexCell(coordinate: center, resolution: resolution) else {
            return []
        }

        let kRings = ringRadius(for: bbox, resolution: resolution)

        // gridDisk excludes self — re-add it so the center is always present.
        var disk = centerCell.neighbors(within: kRings)
        disk.insert(centerCell)

        // Geometry filter: keep only cells whose centroid is inside bbox.
        var inside: [HexCell] = []
        inside.reserveCapacity(disk.count)
        for cell in disk {
            guard let coord = try? cell.center else { continue }
            if bbox.contains(coord) {
                inside.append(cell)
            }
        }

        // Safety cap: if the filter somehow left more than `maxCells`, sort by
        // ring distance from center and truncate the outer rings. Order doesn't
        // affect rendering correctness, but keeping the center is critical.
        guard inside.count > maxCells else { return inside }
        inside.sort { lhs, rhs in
            (centerCell.gridDistance(to: lhs) ?? .max) < (centerCell.gridDistance(to: rhs) ?? .max)
        }
        return Array(inside.prefix(maxCells))
    }

    /// Estimates how many rings of `gridDisk` are needed to cover the bbox.
    ///
    /// Uses half the bbox diagonal (in meters) divided by the hex edge length,
    /// with a 15 % safety margin to account for hex shape and bbox corners.
    private static func ringRadius(for bbox: MapBBox, resolution: HexResolution) -> Int {
        let midLat = (bbox.northEast.latitude + bbox.southWest.latitude) / 2
        let latMeters = (bbox.northEast.latitude - bbox.southWest.latitude) * 111_000
        let lonMeters = (bbox.northEast.longitude - bbox.southWest.longitude)
            * 111_000 * cos(midLat * .pi / 180)
        let diagonalMeters = (latMeters * latMeters + lonMeters * lonMeters).squareRoot()
        let radiusMeters = diagonalMeters / 2
        let edge = max(resolution.averageEdgeMeters, 1)
        let rings = Int((radiusMeters / edge * 1.15).rounded(.up))
        return max(rings, 1)
    }

    /// Picks the finest resolution at which the estimated disk size for `bbox`
    /// stays under `maxCells`. Falls back to coarser resolutions when needed,
    /// down to `r0`. This keeps low-zoom rebuilds bounded *and* full-coverage:
    /// without this step, the cap would chop the disk into a tiny center patch
    /// while the rest of the viewport sits unfilled.
    private static func adjustedResolution(preferred: HexResolution, bbox: MapBBox) -> HexResolution {
        var candidate = preferred
        while candidate.rawValue > 0 {
            let rings = ringRadius(for: bbox, resolution: candidate)
            // Hex disk size: 1 + 6 * sum(1..k) = 1 + 3k(k+1).
            let estimated = 1 + 3 * rings * (rings + 1)
            if estimated <= maxCells { return candidate }
            guard let coarser = HexResolution(rawValue: candidate.rawValue - 1) else { break }
            candidate = coarser
        }
        return candidate
    }
}
#endif

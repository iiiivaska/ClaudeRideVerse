import CoreLocation
@preconcurrency import SwiftyH3

/// Batch operations on collections of H3 cells.
public enum HexCellBatch {

    /// Converts an array of coordinates to a deduplicated set of cells at the given resolution.
    public static func cells(
        for coordinates: [CLLocationCoordinate2D],
        resolution: HexResolution
    ) -> Set<HexCell> {
        var result = Set<HexCell>()
        for coord in coordinates {
            guard let cell = try? HexCell(coordinate: coord, resolution: resolution) else {
                continue
            }
            result.insert(cell)
        }
        return result
    }

    /// Computes the multipolygon boundary of a set of cells.
    ///
    /// Uses H3's `cellsToMultiPolygon` to produce the outer boundary and holes.
    /// Returns an empty `HexMultiPolygon` if the input is empty or the operation fails.
    public static func boundary(of cells: Set<HexCell>) -> HexMultiPolygon {
        guard !cells.isEmpty else { return HexMultiPolygon(polygons: []) }

        let h3Cells = cells.map { H3Cell($0.index) }
        guard let multiPoly: H3MultiPolygon = try? h3Cells.multiPolygon else {
            return HexMultiPolygon(polygons: [])
        }

        let polygons = multiPoly.map { h3Polygon -> HexMultiPolygon.Polygon in
            let outer = h3Polygon.boundary.map(\.coordinates)
            let holes = h3Polygon.holes.map { hole in
                hole.map(\.coordinates)
            }
            return HexMultiPolygon.Polygon(outer: outer, holes: holes)
        }

        return HexMultiPolygon(polygons: polygons)
    }
}

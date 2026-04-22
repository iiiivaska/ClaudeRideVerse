import CoreLocation
import HexCore

extension HexCellSet {

    /// Returns the multipolygon boundary of all cells in the set.
    ///
    /// Delegates to `HexCellBatch.boundary(of:)` which uses H3's
    /// `cellsToMultiPolygon`. Returns an empty multipolygon if the
    /// set is empty or the operation fails.
    public func multiPolygon() -> HexMultiPolygon {
        HexCellBatch.boundary(of: cells)
    }

    /// Flat outer boundaries matching the Jira contract signature.
    ///
    /// Each element is the outer ring of one polygon (holes omitted).
    /// Use ``multiPolygon()`` for the full structure with holes.
    public var outerBoundaries: [[CLLocationCoordinate2D]] {
        multiPolygon().polygons.map(\.outer)
    }
}

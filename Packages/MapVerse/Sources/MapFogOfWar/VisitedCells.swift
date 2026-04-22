import HexGeometry
import MapCore

/// A type that provides visited hex cells for fog-of-war rendering.
///
/// Conforming types supply cells filtered to the current map viewport.
/// The fog renderer calls this protocol to obtain the geometry
/// for building the inverted multipolygon.
///
/// MapFogOfWar does not prescribe how cells are stored or loaded.
/// An adapter in the app layer bridges ``HexCellSet`` from memory,
/// GRDB, or CloudKit into this protocol.
public protocol VisitedCells: Sendable {
    /// Returns visited cells within the bounding box at the given zoom level.
    ///
    /// Implementations should apply viewport culling (with buffer) and
    /// zoom-appropriate compaction via ``FogResolutionPolicy``.
    func cellSet(in bbox: MapBBox, atZoom zoom: Double) -> HexCellSet
}

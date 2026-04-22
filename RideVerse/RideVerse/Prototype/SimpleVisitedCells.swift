import HexCore
import HexGeometry
import MapCore
import MapFogOfWar

/// Zoom-adaptive ``VisitedCells`` adapter for the prototype.
///
/// Stores cells at r9 (finest resolution). On query, converts
/// to the resolution dictated by ``FogResolutionPolicy`` —
/// coarser hexes when zoomed out, fine hexes when zoomed in.
struct SimpleVisitedCells: VisitedCells {
    let cells: HexCellSet

    func cellSet(in bbox: MapBBox, atZoom zoom: Double) -> HexCellSet {
        let targetResolution = FogResolutionPolicy.resolution(forZoom: zoom)

        // If already at target resolution, return as-is.
        guard targetResolution != .r10 else { return cells }

        // Convert each r9 cell to its parent at the target resolution.
        var coarseCells = HexCellSet()
        for cell in cells.cells {
            if let parent = cell.parent(at: targetResolution) {
                coarseCells.insert(parent)
            }
        }
        return coarseCells
    }
}

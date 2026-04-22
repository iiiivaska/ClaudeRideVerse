import CoreLocation
@preconcurrency import SwiftyH3

extension HexCell {

    // MARK: - Neighbors

    /// Returns all cells within `k` grid steps (k-ring), excluding `self`.
    public func neighbors(within k: Int) -> Set<HexCell> {
        guard k > 0 else { return [] }
        let h3Cell = H3Cell(index)
        guard let disk = try? h3Cell.gridDisk(distance: Int32(k)) else { return [] }
        var result = Set<HexCell>()
        for cell in disk where cell.id != index {
            result.insert(HexCell(trusted: cell, resolution: resolution))
        }
        return result
    }

    /// The immediate neighbors of this cell (6 for hexagons, 5 for pentagons).
    public var immediateNeighbors: Set<HexCell> {
        neighbors(within: 1)
    }

    // MARK: - Hierarchy

    /// Returns the parent cell at a coarser resolution. Returns `nil` if the
    /// requested resolution is not coarser than this cell's resolution.
    public func parent(at targetResolution: HexResolution) -> HexCell? {
        guard targetResolution < resolution else { return nil }
        let h3Cell = H3Cell(index)
        guard let parent = try? h3Cell.parent(at: targetResolution.h3Resolution) else { return nil }
        return HexCell(trusted: parent, resolution: targetResolution)
    }

    /// Returns all children at a finer resolution. Returns an empty set if the
    /// requested resolution is not finer than this cell's resolution.
    public func children(at targetResolution: HexResolution) -> Set<HexCell> {
        guard targetResolution > resolution else { return [] }
        let h3Cell = H3Cell(index)
        guard let childCollection = try? h3Cell.children(at: targetResolution.h3Resolution) else {
            return []
        }
        var result = Set<HexCell>()
        for child in childCollection {
            result.insert(HexCell(trusted: child, resolution: targetResolution))
        }
        return result
    }

    // MARK: - Distance

    /// Grid distance to another cell. Returns `nil` if the cells are at
    /// different resolutions or the path crosses a pentagon.
    public func gridDistance(to other: HexCell) -> Int? {
        guard resolution == other.resolution else { return nil }
        let h3Self = H3Cell(index)
        let h3Other = H3Cell(other.index)
        guard let distance = try? h3Self.gridDistance(to: h3Other) else { return nil }
        return Int(distance)
    }
}

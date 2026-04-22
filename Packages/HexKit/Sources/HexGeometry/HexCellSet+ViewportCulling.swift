import HexCore

extension HexCellSet {

    /// Returns cells whose centers fall within the given bounding box,
    /// expanded by 50% to prevent popping at viewport edges.
    ///
    /// This is a brute-force O(n) scan suitable for compacted sets
    /// (typically thousands of cells). The architecture spec envisions
    /// an R-tree index for a future optimization pass.
    public func cells(in bbox: HexBBox) -> HexCellSet {
        let expanded = bbox.expanded(by: 0.5)
        let filtered = cells.filter { cell in
            guard let center = try? cell.center else { return false }
            return expanded.contains(center)
        }
        return HexCellSet(filtered)
    }
}

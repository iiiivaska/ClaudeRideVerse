@preconcurrency import SwiftyH3
import HexCore

extension HexCellSet {

    /// Returns a new set with cells compacted to coarser resolutions
    /// where all children of a parent are present.
    ///
    /// Uses H3's `compactCells` algorithm. For example, if all 7 children
    /// of an r8 parent exist at r9, they collapse into a single r8 cell.
    ///
    /// Returns `self` unchanged if compaction fails (e.g., mixed resolutions
    /// that SwiftyH3 cannot compact).
    public func compacted() -> HexCellSet {
        guard !cells.isEmpty else { return self }

        let h3Cells = cells.map { H3Cell($0.index) }

        guard let compactedH3 = try? h3Cells.compacted else {
            return self
        }

        let compactedHex = Set(compactedH3.compactMap { HexCell(index: $0.id) })
        return HexCellSet(compactedHex)
    }
}

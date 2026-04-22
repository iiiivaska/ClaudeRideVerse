import HexCore

/// A set of H3 hexagonal cells with compaction and geometry operations.
///
/// `HexCellSet` is a value type wrapping `Set<HexCell>`. The architecture
/// spec envisions a future actor-isolated class with hot/cold storage;
/// this struct is the SCRUM-25 foundation for that evolution.
public struct HexCellSet: Sendable, Equatable {

    // MARK: - Storage

    private var storage: Set<HexCell>

    // MARK: - Initializers

    /// Creates an empty cell set.
    public init() {
        self.storage = []
    }

    /// Creates a cell set from an existing set of cells.
    public init(_ cells: Set<HexCell>) {
        self.storage = cells
    }

    /// Creates a cell set from any sequence of cells, deduplicating.
    public init<S: Sequence>(_ cells: S) where S.Element == HexCell {
        self.storage = Set(cells)
    }

    // MARK: - Properties

    /// The number of cells in the set.
    public var count: Int { storage.count }

    /// Whether the set contains no cells.
    public var isEmpty: Bool { storage.isEmpty }

    /// The underlying set of cells (read-only).
    public var cells: Set<HexCell> { storage }

    // MARK: - Mutation

    /// Inserts a cell into the set.
    ///
    /// - Returns: `true` if the cell was newly inserted, `false` if it was already present.
    @discardableResult
    public mutating func insert(_ cell: HexCell) -> Bool {
        storage.insert(cell).inserted
    }

    /// Inserts all cells from a sequence.
    public mutating func insert<S: Sequence>(contentsOf cells: S) where S.Element == HexCell {
        storage.formUnion(cells)
    }

    /// Whether the set contains a specific cell.
    public func contains(_ cell: HexCell) -> Bool {
        storage.contains(cell)
    }

    // MARK: - Set Operations

    /// Returns a new set containing all cells from both sets.
    public func merged(with other: HexCellSet) -> HexCellSet {
        HexCellSet(storage.union(other.storage))
    }
}

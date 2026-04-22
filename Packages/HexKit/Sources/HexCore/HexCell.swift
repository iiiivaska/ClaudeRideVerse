import CoreLocation
@preconcurrency import SwiftyH3

/// A type-safe wrapper around an H3 hexagonal cell index.
///
/// `HexCell` stores only the raw `UInt64` index and the `HexResolution`,
/// making it `Sendable` by default. Coordinate properties are computed on access
/// via SwiftyH3.
public struct HexCell: Hashable, Sendable, CustomStringConvertible {

    /// The raw H3 index.
    public let index: UInt64

    /// The resolution level of this cell.
    public let resolution: HexResolution

    // MARK: - Initializers

    /// Creates a cell from a geographic coordinate at the given resolution.
    public init(coordinate: CLLocationCoordinate2D, resolution: HexResolution) throws {
        let latLng = H3LatLng(coordinate)
        let h3Cell = try latLng.cell(at: resolution.h3Resolution)
        self.index = h3Cell.id
        self.resolution = resolution
    }

    /// Creates a cell from a raw H3 index. Returns `nil` if the index is invalid.
    ///
    /// - Parameters:
    ///   - index: The raw H3 `UInt64` index.
    ///   - strict: When `true`, performs additional validation. Defaults to `false`.
    public init?(index: UInt64, strict: Bool = false) {
        let h3Cell = H3Cell(index)
        guard h3Cell.isValid else { return nil }
        guard let res = HexResolution(h3Resolution: (try? h3Cell.resolution) ?? .res0) else {
            return nil
        }
        if strict {
            // Re-derive to verify structural integrity
            guard let center = try? h3Cell.center else { return nil }
            let roundTrip = try? center.cell(at: res.h3Resolution)
            guard roundTrip?.id == index else { return nil }
        }
        self.index = index
        self.resolution = res
    }

    /// Internal initializer skipping validation (for trusted SwiftyH3 outputs).
    init(trusted h3Cell: H3Cell, resolution: HexResolution) {
        self.index = h3Cell.id
        self.resolution = resolution
    }

    // MARK: - Computed Properties

    /// The geographic center of this cell.
    public var center: CLLocationCoordinate2D {
        get throws {
            let h3Cell = H3Cell(index)
            let latLng = try h3Cell.center
            return latLng.coordinates
        }
    }

    /// The boundary vertices of this cell (6 for hexagons, 5 for pentagons).
    public var boundary: [CLLocationCoordinate2D] {
        get throws {
            let h3Cell = H3Cell(index)
            let loop = try h3Cell.boundary
            return loop.map(\.coordinates)
        }
    }

    /// Whether this cell is one of the 12 pentagons at its resolution level.
    public var isPentagon: Bool {
        H3Cell(index).isPentagon
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(index)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.index == rhs.index
    }

    // MARK: - CustomStringConvertible

    public var description: String {
        H3Cell(index).description
    }
}

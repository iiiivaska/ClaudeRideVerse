import HexCore

/// Maps map zoom levels to H3 resolutions for adaptive fog detail.
///
/// At lower zoom levels, coarser resolutions reduce polygon vertex count
/// and improve MapLibre rendering performance. At close zoom,
/// full r9 resolution provides detailed hex boundaries.
public enum FogResolutionPolicy: Sendable {

    /// Returns the H3 resolution appropriate for the given map zoom level.
    ///
    /// | Zoom     | Resolution | Hex edge   |
    /// |----------|-----------|------------|
    /// | >= 14    | r10       | ~65 m      |
    /// | 12 -- 13 | r9        | ~174 m     |
    /// | 10 -- 11 | r8        | ~461 m     |
    /// | 8 -- 9   | r7        | ~1.2 km    |
    /// | 6 -- 7   | r6        | ~3.2 km    |
    /// | 4 -- 5   | r5        | ~8.5 km    |
    /// | 2 -- 3   | r4        | ~22.6 km   |
    /// | < 2      | r3        | ~59.8 km   |
    public static func resolution(forZoom zoom: Double) -> HexResolution {
        if zoom >= 14 {
            return .r10
        } else if zoom >= 12 {
            return .r9
        } else if zoom >= 10 {
            return .r8
        } else if zoom >= 8 {
            return .r7
        } else if zoom >= 6 {
            return .r6
        } else if zoom >= 4 {
            return .r5
        } else if zoom >= 2 {
            return .r4
        } else {
            return .r3
        }
    }
}

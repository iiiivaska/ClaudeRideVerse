import HexCore

/// Maps map zoom levels to H3 resolutions for adaptive fog detail.
///
/// At lower zoom levels, coarser resolutions reduce polygon vertex count
/// and improve MapLibre rendering performance. At close zoom,
/// full r9 resolution provides detailed hex boundaries.
public enum FogResolutionPolicy: Sendable {

    /// Returns the H3 resolution appropriate for the given map zoom level.
    ///
    /// | Zoom    | Resolution | Hex edge |
    /// |---------|-----------|----------|
    /// | > 14    | r9        | ~174 m   |
    /// | 10 -- 14 | r7        | ~1.2 km  |
    /// | < 10    | r5        | ~8.5 km  |
    public static func resolution(forZoom zoom: Double) -> HexResolution {
        if zoom > 14 {
            return .r9
        } else if zoom >= 10 {
            return .r7
        } else {
            return .r5
        }
    }
}

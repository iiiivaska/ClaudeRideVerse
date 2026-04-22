import Foundation
@preconcurrency import SwiftyH3

/// Type-safe H3 resolution level (0–15).
///
/// Resolution 9 (~174 m edge) is the default for fog-of-war in RideVerse.
/// Lower resolutions cover larger areas; higher resolutions are more granular.
public enum HexResolution: Int, Sendable, CaseIterable, Comparable {
    case r0 = 0
    case r1 = 1
    case r2 = 2
    case r3 = 3
    case r4 = 4
    case r5 = 5
    case r6 = 6
    case r7 = 7
    case r8 = 8
    case r9 = 9
    case r10 = 10
    case r11 = 11
    case r12 = 12
    case r13 = 13
    case r14 = 14
    case r15 = 15

    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    // MARK: - Metric Properties

    /// Average hexagon edge length in meters at this resolution.
    public var averageEdgeMeters: Double {
        Self.edgeLengths[rawValue]
    }

    /// Average hexagon area in square meters at this resolution.
    public var averageAreaSquareMeters: Double {
        Self.areas[rawValue]
    }

    // MARK: - H3 resolution table (source: h3geo.org/docs/core-library/restable)

    private static let edgeLengths: [Double] = [
        1107_712.591,   // r0
        418_676.005,    // r1
        158_244.655,    // r2
        59_810.857,     // r3
        22_606.379,     // r4
        8_544.408,      // r5
        3_229.482,      // r6
        1_220.629,      // r7
        461.354,        // r8
        174.375,        // r9
        65.907,         // r10
        24.910,         // r11
        9.415,          // r12
        3.559,          // r13
        1.345,          // r14
        0.509,          // r15
    ]

    private static let areas: [Double] = [
        4_357_449_416_078.392,  // r0
        609_788_441_794.134,    // r1
        86_801_780_398.997,     // r2
        12_393_434_655.088,     // r3
        1_770_347_654.491,      // r4
        252_903_858.182,        // r5
        36_129_062.164,         // r6
        5_161_293.360,          // r7
        737_327.598,            // r8
        105_332.513,            // r9
        15_047.502,             // r10
        2_149.643,              // r11
        307.092,                // r12
        43.870,                 // r13
        6.267,                  // r14
        0.895,                  // r15
    ]

    // MARK: - Internal SwiftyH3 Bridge

    var h3Resolution: H3Cell.Resolution {
        H3Cell.Resolution(rawValue: Int32(rawValue))!
    }

    init?(h3Resolution: H3Cell.Resolution) {
        self.init(rawValue: Int(h3Resolution.rawValue))
    }
}

import Foundation

/// Errors that can occur during H3 hexagonal grid operations.
public enum HexError: Error, Sendable {
    case invalidCoordinate
    case resolutionMismatch(expected: HexResolution, got: HexResolution)
    case antimeridianCrossing
    case pentagonEncountered
}

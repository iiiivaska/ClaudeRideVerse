import SwiftUI

/// Visual styling for the fog-of-war overlay.
public struct FogStyle: Sendable, Equatable {

    /// Color of the unexplored fog area.
    public var fogColor: Color

    /// Opacity of the fog overlay (0.0 = transparent, 1.0 = opaque).
    public var opacity: Double

    /// Optional highlight color for edges where fog meets explored territory.
    public var edgeColor: Color?

    /// Whether newly revealed cells animate with a pulse effect.
    public var pulseNewCells: Bool

    public init(
        fogColor: Color = .black,
        opacity: Double = 0.7,
        edgeColor: Color? = nil,
        pulseNewCells: Bool = true
    ) {
        self.fogColor = fogColor
        self.opacity = opacity
        self.edgeColor = edgeColor
        self.pulseNewCells = pulseNewCells
    }

    /// Black fog at 70% opacity, no edge highlight, pulse animation enabled.
    public static let `default` = FogStyle()
}

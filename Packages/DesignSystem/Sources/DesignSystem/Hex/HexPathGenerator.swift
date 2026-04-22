import CoreGraphics
import SwiftUI

/// Pure geometry for pointy-top hexagons. Mirrors the prototype's `hexPts`
/// helper (`Design/Prototype/FogRide Prototype.html:74`) — 6 vertices at
/// angles `60°·i − 30°`. All hexes in FogRide are pointy-top; no flat-top.
public enum HexPathGenerator {

    /// Vertex count for a hexagon.
    public static let vertexCount = 6

    /// Returns the 6 points that form a pointy-top hex centered at `center` with the
    /// given circumradius. Order: starts at the top vertex (angle −30° → 30° offset)
    /// and proceeds clockwise.
    public static func hexPoints(center: CGPoint, radius: CGFloat) -> [CGPoint] {
        (0..<vertexCount).map { i in
            let angle = .pi / 180 * (60.0 * Double(i) - 30.0)
            return CGPoint(
                x: center.x + radius * CGFloat(cos(angle)),
                y: center.y + radius * CGFloat(sin(angle))
            )
        }
    }

    /// SwiftUI `Path` wrapping `hexPoints` — ready to stroke or fill.
    public static func hexPath(center: CGPoint, radius: CGFloat) -> Path {
        let points = hexPoints(center: center, radius: radius)
        var path = Path()
        path.move(to: points[0])
        for point in points.dropFirst() {
            path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }

    /// Spacing between hex centers on a pointy-top grid.
    /// `dx = r·√3`, `dy = r·1.5`; odd rows offset by `dx/2` (used by
    /// `HexGridIllustration` in F.3.4).
    public static func rowSpacing(radius: CGFloat) -> CGFloat { radius * 1.5 }
    public static func columnSpacing(radius: CGFloat) -> CGFloat { radius * CGFloat(3.0.squareRoot()) }
}

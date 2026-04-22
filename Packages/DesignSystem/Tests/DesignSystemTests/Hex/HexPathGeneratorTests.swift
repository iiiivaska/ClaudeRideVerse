import CoreGraphics
import Testing
@testable import DesignSystem

@Suite("HexPathGenerator — pointy-top geometry mirrors prototype hexPts")
struct HexPathGeneratorTests {

    @Test("Returns exactly 6 vertices")
    func sixVertices() {
        let points = HexPathGenerator.hexPoints(center: .zero, radius: 10)
        #expect(points.count == 6)
    }

    @Test("First vertex lies on the top (negative y in UIKit coords) — pointy-top")
    func firstVertexIsTopVertex() {
        let points = HexPathGenerator.hexPoints(center: .zero, radius: 20)
        // angle = 60·0 − 30 = −30° → cos=√3/2, sin=−1/2 → (+17.32, −10)
        #expect(approx(points[0].x, 17.3205))
        #expect(approx(points[0].y, -10.0))
    }

    @Test("Every vertex is exactly `radius` away from center")
    func verticesOnCircle() {
        let center = CGPoint(x: 100, y: 100)
        let r: CGFloat = 15
        let points = HexPathGenerator.hexPoints(center: center, radius: r)
        for point in points {
            let dx = point.x - center.x
            let dy = point.y - center.y
            let distance = (dx * dx + dy * dy).squareRoot()
            #expect(approx(distance, r))
        }
    }

    @Test("Adjacent edges have equal length (regular hexagon)")
    func regularHexagon() {
        let points = HexPathGenerator.hexPoints(center: CGPoint(x: 50, y: 50), radius: 12)
        var edgeLengths: [CGFloat] = []
        for i in 0..<points.count {
            let a = points[i]
            let b = points[(i + 1) % points.count]
            let dx = b.x - a.x
            let dy = b.y - a.y
            edgeLengths.append((dx * dx + dy * dy).squareRoot())
        }
        let first = edgeLengths[0]
        for length in edgeLengths {
            #expect(approx(length, first, epsilon: 0.001))
        }
        // Pointy-top hex edge length equals the circumradius.
        #expect(approx(first, 12.0, epsilon: 0.001))
    }

    @Test("Path closes back to the first vertex")
    func pathCloses() {
        let path = HexPathGenerator.hexPath(center: .zero, radius: 10)
        let bounds = path.boundingRect
        // Pointy-top hex with r=10: width = r·√3 ≈ 17.32, height = 2·r = 20
        #expect(approx(Double(bounds.width), 17.320, epsilon: 0.01))
        #expect(approx(Double(bounds.height), 20.0, epsilon: 0.01))
    }

    @Test("Row/column spacing match pointy-top tessellation constants")
    func spacingConstants() {
        let r: CGFloat = 20
        #expect(approx(HexPathGenerator.rowSpacing(radius: r), 30.0))
        #expect(approx(HexPathGenerator.columnSpacing(radius: r), 34.641, epsilon: 0.01))
    }
}

// MARK: - Helpers

private func approx(_ a: CGFloat, _ b: CGFloat, epsilon: CGFloat = 0.01) -> Bool {
    abs(a - b) < epsilon
}

private func approx(_ a: Double, _ b: Double, epsilon: Double = 0.01) -> Bool {
    abs(a - b) < epsilon
}

import SwiftUI

/// 13-hex onboarding illustration — a filled honeycomb "flower".
/// Mirrors the prototype's `HexIllo` React component:
/// `Design/Prototype/FogRide Prototype.html:220`.
public struct HexGridIllustration: View {

    private let radius: CGFloat
    private let accentState: HexCellState

    public init(radius: CGFloat = 19, accentState: HexCellState = .newUnlock) {
        self.radius = radius
        self.accentState = accentState
    }

    public var body: some View {
        let canvasSize = computedSize()
        ZStack {
            ForEach(Array(layout().enumerated()), id: \.offset) { _, coord in
                HexCell(state: cellState(at: coord), radius: radius)
                    .offset(x: coord.x, y: coord.y)
            }
        }
        .frame(width: canvasSize.width, height: canvasSize.height)
    }

    /// Pointy-top honeycomb arranged into rows of 1 / 2 / 3 / 2 / 1 plus
    /// two extra hexes that extend the middle row. Centered on origin.
    private func layout() -> [CGPoint] {
        let dx = HexPathGenerator.columnSpacing(radius: radius) // r·√3
        let dy = HexPathGenerator.rowSpacing(radius: radius)    // r·1.5
        return [
            CGPoint(x: 0, y: -2 * dy),
            CGPoint(x: -dx / 2, y: -dy),
            CGPoint(x: dx / 2, y: -dy),
            CGPoint(x: -dx, y: 0),
            CGPoint(x: 0, y: 0),
            CGPoint(x: dx, y: 0),
            CGPoint(x: -3 * dx / 2, y: dy),
            CGPoint(x: -dx / 2, y: dy),
            CGPoint(x: dx / 2, y: dy),
            CGPoint(x: 3 * dx / 2, y: dy),
            CGPoint(x: -dx, y: 2 * dy),
            CGPoint(x: 0, y: 2 * dy),
            CGPoint(x: dx, y: 2 * dy),
        ]
    }

    private func computedSize() -> CGSize {
        let points = layout()
        let xs = points.map(\.x)
        let ys = points.map(\.y)
        let width = ((xs.max() ?? 0) - (xs.min() ?? 0)) + radius * 2
        let height = ((ys.max() ?? 0) - (ys.min() ?? 0)) + radius * 2
        return CGSize(width: width, height: height)
    }

    /// The centre hex gets the accent state; the rest sit in `explored`.
    private func cellState(at point: CGPoint) -> HexCellState {
        point == .zero ? accentState : .explored
    }
}

#Preview("HexGridIllustration") {
    HexGridIllustration()
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.fogBg)
        .preferredColorScheme(.dark)
}

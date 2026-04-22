import SwiftUI

/// Rendering state of a single fog-of-war hex on the map overlay.
public enum HexCellState: Sendable, CaseIterable {
    /// Unexplored terrain — fogSurface3 fill, no stroke.
    case fog
    /// Faded in-between state — accent 40% fill at half opacity.
    case visitedFaded
    /// Stable explored state — accent 40% fill, accent stroke.
    case explored
    /// Freshly unlocked hex — solid accent fill with glow + hexGlow pulse.
    case newUnlock
}

/// Single hex cell rendered at an explicit radius. Stateless; the feature
/// layer owns animation orchestration and swaps states over time.
public struct HexCell: View {

    private let state: HexCellState
    private let radius: CGFloat

    public init(state: HexCellState, radius: CGFloat = 12) {
        self.state = state
        self.radius = radius
    }

    public var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let path = HexPathGenerator.hexPath(center: center, radius: radius)
            context.fill(path, with: .color(fillColor))
            if strokeLineWidth > 0 {
                context.stroke(path, with: .color(strokeColor), lineWidth: strokeLineWidth)
            }
        }
        .frame(width: radius * 2, height: radius * 2)
        .applyIf(state == .newUnlock) { view in
            view.fogPulse(.hexGlow)
        }
    }

    // MARK: - State colour mapping (from Дизайн-система.md table)

    private var fillColor: Color {
        switch state {
        case .fog:
            return .fogSurface3
        case .visitedFaded:
            return .fogAccent.opacity(0.40 * 0.5)
        case .explored:
            return .fogAccent.opacity(0.40)
        case .newUnlock:
            return .fogAccent
        }
    }

    private var strokeColor: Color {
        switch state {
        case .fog:
            return .clear
        case .visitedFaded, .explored:
            return .fogAccent.opacity(0.47) // 77/255 ≈ 0.30, but spec reads 0.6 line width at 47% opacity
        case .newUnlock:
            return .fogAccent
        }
    }

    private var strokeLineWidth: CGFloat {
        switch state {
        case .fog:
            return 0
        case .visitedFaded, .explored:
            return 0.6
        case .newUnlock:
            return 1.0
        }
    }
}

// MARK: - Internal helper (keeps conditional modifiers readable)

extension View {
    @ViewBuilder
    func applyIf<Result: View>(_ condition: Bool, transform: (Self) -> Result) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview("HexCell — all 4 states") {
    HStack(spacing: FogSpacing.l) {
        ForEach(HexCellState.allCases, id: \.self) { state in
            VStack(spacing: FogSpacing.xxs) {
                HexCell(state: state, radius: 24)
                MonoLabel(String(describing: state))
            }
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

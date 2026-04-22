import SwiftUI

/// Shared pulse recipes used by REC dot, location ring, and hex unlock.
/// Driven by `TimelineView(.animation)` so no Timer / GCD — compatible with
/// Swift 6 strict concurrency.
public enum PulseStyle: Sendable, CaseIterable {
    /// Red box-shadow pulse — REC indicator (1.5s cycle).
    case red
    /// Accent radial ring — user location on map (2s cycle, radius 10→22).
    case accent
    /// Hex unlock breathing — opacity 0.6 → 1.0, 1.8s cycle.
    case hexGlow

    /// Total cycle length in seconds.
    public var period: Double {
        switch self {
        case .red: return 1.5
        case .accent: return 2.0
        case .hexGlow: return 1.8
        }
    }
}

public extension View {
    /// Applies a breathing/pulse effect for the given style. Wraps the view in a
    /// `TimelineView(.animation)` so animation keeps running independently of
    /// external state changes.
    func fogPulse(_ style: PulseStyle) -> some View {
        modifier(PulseAnimation(style: style))
    }
}

struct PulseAnimation: ViewModifier {

    let style: PulseStyle

    func body(content: Content) -> some View {
        TimelineView(.animation) { context in
            let phase = phase(for: context.date)
            applied(content: content, phase: phase)
        }
    }

    @ViewBuilder
    private func applied(content: Content, phase: Double) -> some View {
        switch style {
        case .red:
            // 0 → 70% into cycle box-shadow expands from 0→7px with fading red
            let expand = min(1.0, phase / 0.7)
            content
                .shadow(
                    color: Color.fogRed.opacity(0.6 * (1.0 - expand)),
                    radius: 7 * expand,
                    x: 0,
                    y: 0
                )

        case .accent:
            // r 10 → 22, opacity 0.4 → 0
            content
                .scaleEffect(1.0 + 1.2 * phase)
                .opacity(0.4 * (1.0 - phase))

        case .hexGlow:
            // opacity 0.6 ↔ 1.0 (triangle wave)
            let eased = cosEase(phase: phase)
            content.opacity(0.6 + 0.4 * eased)
        }
    }

    private func phase(for date: Date) -> Double {
        let seconds = date.timeIntervalSinceReferenceDate
        let cycle = seconds.truncatingRemainder(dividingBy: style.period)
        return cycle / style.period // 0.0 ... 1.0
    }

    private func cosEase(phase: Double) -> Double {
        // 0 at phase 0, 1 at phase 0.5, 0 at phase 1 — ease-in-out feel.
        (1 - cos(phase * 2 * .pi)) / 2
    }
}

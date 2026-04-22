import SwiftUI

/// 36×36 circular glass container for single-icon map controls (layers,
/// crosshair, compass). Tappable when an action is supplied.
public struct GlassCircle<Content: View>: View {

    public static var defaultSize: CGFloat { 36 }

    private let size: CGFloat
    private let action: (@Sendable () -> Void)?
    private let content: Content

    public init(
        size: CGFloat = GlassCircle.defaultSize,
        action: (@Sendable () -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Group {
            if let action {
                Button(action: action) { body(inner: content) }
                    .buttonStyle(.plain)
            } else {
                body(inner: content)
            }
        }
    }

    private func body(inner: Content) -> some View {
        inner
            .frame(width: size, height: size)
            .clipShape(.circle)
            .fogGlass(level: .control)
            .clipShape(.circle)
    }
}

#Preview("GlassCircle") {
    HStack(spacing: FogSpacing.m) {
        GlassCircle {
            Image(systemName: "square.stack.3d.up")
                .foregroundStyle(Color.fogTextPrimary)
        }
        GlassCircle {
            Image(systemName: "location")
                .foregroundStyle(Color.fogAccent)
        }
        GlassCircle(size: 44) {
            Image(systemName: "xmark")
                .foregroundStyle(Color.fogTextPrimary)
        }
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

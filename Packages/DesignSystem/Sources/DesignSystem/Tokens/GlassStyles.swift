import SwiftUI

/// Levels of Liquid Glass used across FogRide. Each level has its own blur/opacity/border recipe
/// tuned in the React prototype (`Design/Prototype/FogRide Prototype.html`).
public enum FogGlassLevel: Sendable, CaseIterable {
    /// Floating tab bar — strongest blur + dual shadow + inset highlight.
    case tabBar
    /// Recording HUD and similar floating cards over content.
    case hud
    /// Map pills, glass circles, compass button — lightest.
    case control
}

public extension View {
    /// Applies the standard FogRide Liquid Glass recipe.
    ///
    /// The modifier composes iOS 26 `.glassEffect(.regular)` for `.hud` / `.control` and uses a
    /// handcrafted stack (ultraThinMaterial + tuned tint + dual shadow) for `.tabBar` since the
    /// prototype's floating pill shadow recipe does not map 1:1 onto `.glassEffect`.
    func fogGlass(level: FogGlassLevel) -> some View {
        modifier(FogGlassModifier(level: level))
    }
}

struct FogGlassModifier: ViewModifier {
    let level: FogGlassLevel

    func body(content: Content) -> some View {
        switch level {
        case .tabBar:
            content
                .background(
                    ZStack {
                        Color.fogGlassBgTabBar
                        Rectangle().fill(.ultraThinMaterial)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FogRadius.pill, style: .continuous)
                        .strokeBorder(Color.fogGlassBorderTabBar, lineWidth: 0.5)
                )
                .fogShadow(FogShadow.tabBarPrimary)
                .fogShadow(FogShadow.tabBarSecondary)

        case .hud:
            content
                .background(
                    ZStack {
                        Color.fogGlassBg
                        Rectangle().fill(.ultraThinMaterial)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FogRadius.xxl, style: .continuous)
                        .strokeBorder(Color.fogGlassBorder, lineWidth: 1)
                )
                .fogShadow(FogShadow.hud)

        case .control:
            content
                .background(
                    ZStack {
                        Color.fogGlassBg
                        Rectangle().fill(.ultraThinMaterial)
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: FogRadius.pill, style: .continuous)
                        .strokeBorder(Color.fogGlassBorder, lineWidth: 1)
                )
        }
    }
}

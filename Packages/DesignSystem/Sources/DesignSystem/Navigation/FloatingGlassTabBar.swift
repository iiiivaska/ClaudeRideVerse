import SwiftUI

/// Tab descriptor for `FloatingGlassTabBar`. `id` is the stable selection value
/// consumed by a `Binding<Selection>`; `icon` and `label` render inside the pill.
public struct FogTab<Selection: Hashable>: Identifiable {
    public let id: Selection
    public let icon: Image
    public let label: String

    public init(id: Selection, icon: Image, label: String) {
        self.id = id
        self.icon = icon
        self.label = label
    }
}

/// iOS 26 floating glass tab bar — custom overlay (NOT a `TabView` wrapper).
/// The prototype places this bar as `position:absolute;bottom:0` with the
/// tuned blur/saturate/dual-shadow recipe; that composition cannot be
/// expressed via `TabView + Tab` API, so this is a drop-in replacement for
/// the system bar.
///
/// Usage:
/// ```swift
/// NavigationStack {
///     MapScreen()
/// }
/// .safeAreaInset(edge: .bottom) {
///     FloatingGlassTabBar(selection: $selected, items: tabs)
/// }
/// ```
public struct FloatingGlassTabBar<Selection: Hashable>: View {

    @Binding private var selection: Selection
    private let items: [FogTab<Selection>]

    public init(selection: Binding<Selection>, items: [FogTab<Selection>]) {
        self._selection = selection
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 2) {
            ForEach(items) { tab in
                TabButton(
                    tab: tab,
                    isActive: tab.id == selection,
                    onTap: { selection = tab.id }
                )
            }
        }
        .padding(5)
        .clipShape(.rect(cornerRadius: FogRadius.pill, style: .continuous))
        .fogGlass(level: .tabBar)
        .padding(.horizontal, FogSpacing.m)
        .padding(.bottom, FogSpacing.xl + 2)
    }
}

// MARK: - Tab button

private struct TabButton<Selection: Hashable>: View {
    let tab: FogTab<Selection>
    let isActive: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2.5) {
                tab.icon
                    .font(.system(size: 22, weight: .regular))
                    .foregroundStyle(isActive ? Color.fogAccent : Color.fogTabInactive)
                Text(tab.label)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .tracking(0.2)
                    .foregroundStyle(isActive ? Color.fogAccent : Color.fogTabInactive)
            }
            .padding(.vertical, 7)
            .padding(.horizontal, 15)
            .frame(minWidth: 60)
            .background(
                isActive ? Color.fogAccentSoft : Color.clear,
                in: .rect(cornerRadius: FogRadius.pill, style: .continuous)
            )
            .contentShape(.rect)
            .animation(.easeInOut(duration: 0.18), value: isActive)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(tab.label))
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

#Preview("FloatingGlassTabBar") {
    @Previewable @State var selection = "map"
    let tabs: [FogTab<String>] = [
        .init(id: "map", icon: Image(systemName: "map"), label: "Map"),
        .init(id: "rides", icon: Image(systemName: "figure.outdoor.cycle"), label: "Rides"),
        .init(id: "stats", icon: Image(systemName: "chart.bar"), label: "Stats"),
        .init(id: "profile", icon: Image(systemName: "person"), label: "Profile"),
    ]
    return VStack {
        Spacer()
        FloatingGlassTabBar(selection: $selection, items: tabs)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

import SwiftUI

/// Public preview gallery of every DesignSystem component. Embed this view
/// in any `App` target (the main RideVerse app, a dedicated gallery target,
/// or a `#Preview`) to visually validate tokens, primitives, buttons, cards,
/// hex states, indicators, navigation, and onboarding surfaces.
///
/// Example:
/// ```swift
/// @main
/// struct DesignSystemGalleryApp: App {
///     var body: some Scene {
///         WindowGroup {
///             NavigationStack {
///                 DesignSystemGallery()
///             }
///             .preferredColorScheme(.dark)
///         }
///     }
/// }
/// ```
public struct DesignSystemGallery: View {

    public init() {}

    public var body: some View {
        List {
            Section {
                NavigationLink("Tokens") { TokensSection() }
                NavigationLink("Primitives") { PrimitivesSection() }
                NavigationLink("Buttons") { ButtonsSection() }
                NavigationLink("Cards") { CardsSection() }
                NavigationLink("Hex cells") { HexSection() }
                NavigationLink("Indicators") { IndicatorsSection() }
                NavigationLink("Navigation") { NavigationSection() }
                NavigationLink("Onboarding") { OnboardingSection() }
            } header: {
                MonoLabel("DesignSystem v0.1")
            }
            .listRowBackground(Color.fogSurface1)
        }
        .navigationTitle("FogRide DS")
        .scrollContentBackground(.hidden)
        .background(Color.fogBg)
        .preferredColorScheme(.dark)
    }
}

// MARK: - Sections

private struct TokensSection: View {
    var body: some View {
        GalleryPage(title: "Tokens") {
            swatch("Surfaces", colors: [
                ("bg", .fogBg),
                ("bg1", .fogSurface1),
                ("bg2", .fogSurface2),
                ("bg3", .fogSurface3),
            ])
            swatch("Accent", colors: [
                ("acc", .fogAccent),
                ("accSoft", .fogAccentSoft),
                ("accBorder", .fogAccentBorder),
            ])
            swatch("Status", colors: [
                ("green", .fogGreen),
                ("red", .fogRed),
                ("orange", .fogOrange),
                ("yellow", .fogYellow),
            ])
            swatch("Text", colors: [
                ("tp", .fogTextPrimary),
                ("ts", .fogTextSecondary),
                ("tt", .fogTextTertiary),
                ("tq", .fogTextQuaternary),
            ])
        }
    }

    private func swatch(_ title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: FogSpacing.xs) {
            MonoLabel(title)
            HStack(spacing: FogSpacing.xs) {
                ForEach(Array(colors.enumerated()), id: \.offset) { _, entry in
                    VStack(spacing: 4) {
                        RoundedRectangle(cornerRadius: FogRadius.xs)
                            .fill(entry.1)
                            .frame(width: 64, height: 64)
                            .overlay(
                                RoundedRectangle(cornerRadius: FogRadius.xs)
                                    .strokeBorder(Color.fogSeparator, lineWidth: 1)
                            )
                        MonoLabel(entry.0)
                    }
                }
            }
        }
    }
}

private struct PrimitivesSection: View {
    var body: some View {
        GalleryPage(title: "Primitives") {
            VStack(alignment: .leading, spacing: FogSpacing.s) {
                MonoLabel("MonoLabel")
                MonoLabel("Distance")
            }
            VStack(alignment: .leading, spacing: FogSpacing.s) {
                MonoLabel("MonoVal — sizes")
                HStack(spacing: FogSpacing.m) {
                    MonoVal("24.8", size: .xl)
                    MonoVal("342", size: .lg, color: .fogAccent)
                    MonoVal("1:23", size: .md)
                    MonoVal("18.3", size: .sm, color: .fogTextSecondary)
                }
            }
            VStack(alignment: .leading, spacing: FogSpacing.s) {
                MonoLabel("Glass primitives")
                GlassPill {
                    MonoVal("12.3", size: .md, color: .fogAccent)
                    MonoLabel("km")
                }
                HStack(spacing: FogSpacing.m) {
                    GlassCircle {
                        Image(systemName: "square.stack.3d.up")
                            .foregroundStyle(Color.fogTextPrimary)
                    }
                    GlassCircle {
                        Image(systemName: "location")
                            .foregroundStyle(Color.fogAccent)
                    }
                }
            }
        }
    }
}

private struct ButtonsSection: View {
    var body: some View {
        GalleryPage(title: "Buttons") {
            Button("Start Ride") { }
                .buttonStyle(.fogPrimary)
            Button("Not now") { }
                .buttonStyle(.fogSecondary)
            HStack {
                Spacer()
                StopButton { }
                Spacer()
            }
            Button("I have an account") { }
                .buttonStyle(.fogLink)
        }
    }
}

private struct CardsSection: View {
    var body: some View {
        GalleryPage(title: "Cards") {
            MonoLabel("GlassHUDCard")
            GlassHUDCard {
                MetricCell4Grid(cells: [
                    .init(value: "18.3", label: "km/h"),
                    .init(value: "342", label: "hex", valueColor: .fogAccent),
                    .init(value: "1:23", label: "moving"),
                    .init(value: "+47", label: "elev", valueColor: .fogGreen),
                ])
            }
            MonoLabel("StatCard2x2")
            StatCard2x2(cells: [
                .init(value: "18.3", label: "distance"),
                .init(value: "342", label: "hex", valueColor: .fogAccent),
                .init(value: "1:23", label: "moving"),
                .init(value: "+47", label: "elev", valueColor: .fogGreen),
            ])
            MonoLabel("GroupedCard")
            GroupedCard {
                VStack(spacing: 0) {
                    settingsRow("Auto-pause", value: "On")
                    Divider().overlay(Color.fogSeparator)
                    settingsRow("Units", value: "Metric")
                }
            }
            MonoLabel("UpsellCard")
            UpsellCard {
                VStack(alignment: .leading, spacing: FogSpacing.s) {
                    MonoLabel("Premium")
                    Text("Unlock offline maps")
                        .font(.fogBody)
                        .foregroundStyle(Color.fogTextPrimary)
                }
                .padding(FogSpacing.m)
            }
        }
    }

    private func settingsRow(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.fogBody)
                .foregroundStyle(Color.fogTextPrimary)
            Spacer()
            Text(value)
                .font(.fogBody)
                .foregroundStyle(Color.fogTextTertiary)
        }
        .padding(.horizontal, FogSpacing.m)
        .padding(.vertical, FogSpacing.s)
    }
}

private struct HexSection: View {
    var body: some View {
        GalleryPage(title: "Hex") {
            MonoLabel("States")
            HStack(spacing: FogSpacing.l) {
                ForEach(HexCellState.allCases, id: \.self) { state in
                    VStack(spacing: FogSpacing.xxs) {
                        HexCell(state: state, radius: 24)
                        MonoLabel(String(describing: state))
                    }
                }
            }
            MonoLabel("Grid illustration")
            HexGridIllustration()
        }
    }
}

private struct IndicatorsSection: View {
    var body: some View {
        GalleryPage(title: "Indicators") {
            HStack(spacing: FogSpacing.l) {
                VStack(spacing: FogSpacing.xxs) {
                    RecPulseDot()
                        .frame(width: 20, height: 20)
                    MonoLabel("REC")
                }
                VStack(spacing: FogSpacing.xxs) {
                    LocationPulseRing()
                        .frame(width: 60, height: 60)
                    MonoLabel("Location")
                }
                VStack(spacing: FogSpacing.xxs) {
                    HexGlowPulseExample()
                    MonoLabel("Hex glow")
                }
            }
        }
    }
}

private struct NavigationSection: View {

    @State private var selection = "map"

    var body: some View {
        GalleryPage(title: "Navigation") {
            MonoLabel("FloatingGlassTabBar")
            VStack(spacing: 0) {
                Rectangle()
                    .fill(Color.fogSurface1)
                    .frame(height: 140)
                FloatingGlassTabBar(
                    selection: $selection,
                    items: [
                        .init(id: "map", icon: Image(systemName: "map"), label: "Map"),
                        .init(id: "rides", icon: Image(systemName: "figure.outdoor.cycle"), label: "Rides"),
                        .init(id: "stats", icon: Image(systemName: "chart.bar"), label: "Stats"),
                        .init(id: "profile", icon: Image(systemName: "person"), label: "Profile"),
                    ]
                )
            }
            .background(Color.fogBg)
        }
    }
}

private struct OnboardingSection: View {
    var body: some View {
        GalleryPage(title: "Onboarding") {
            MonoLabel("OnboardingDots")
            VStack(spacing: FogSpacing.m) {
                OnboardingDots(activeIndex: 0, total: 4)
                OnboardingDots(activeIndex: 2, total: 4)
                OnboardingDots(activeIndex: 3, total: 4)
            }
            MonoLabel("OBIconContainer")
            HStack(spacing: FogSpacing.l) {
                OBIconContainer(tone: .accent) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.fogAccent)
                }
                OBIconContainer(tone: .red) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color.fogRed)
                }
            }
        }
    }
}

// MARK: - Shared page scaffold

private struct GalleryPage<Content: View>: View {

    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: FogSpacing.l) {
                content
            }
            .padding(FogSpacing.m)
        }
        .navigationTitle(title)
        .background(Color.fogBg)
    }
}

#Preview("DesignSystemGallery") {
    NavigationStack {
        DesignSystemGallery()
    }
}

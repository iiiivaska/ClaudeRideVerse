# DesignSystem

Liquid Glass design tokens and components for **FogRide** (RideVerse, iOS 26+).
Dark-first, no Light theme. Tokens mirror the React prototype at
`Design/Prototype/FogRide Prototype.html` byte-for-byte.

## Install

The package lives in `Packages/DesignSystem` inside the RideVerse workspace and
is already wired into `RideVerse.xcodeproj` — just `import DesignSystem` in any
feature module.

## Contents

| Area | Files |
|---|---|
| Tokens | `Color+FogRide`, `Font+FogRide`, `Metrics`, `GlassStyles` |
| Primitives | `MonoLabel`, `MonoVal`, `GlassPill`, `GlassCircle` |
| Buttons | `PrimaryButton`, `SecondaryButton`, `StopButton`, `LinkButton` |
| Hex | `HexPathGenerator`, `HexCell`, `HexGridIllustration` |
| Cards | `GlassHUDCard`, `MetricCell4Grid`, `StatCard2x2`, `GroupedCard`, `UpsellCard` |
| Navigation | `FloatingGlassTabBar` |
| Indicators | `RecPulseDot`, `LocationPulseRing`, `fogHexGlow()` |
| Onboarding | `OnboardingDots`, `OBIconContainer` |
| Gallery | `DesignSystemGallery` (embed to visually validate every piece) |
| Animations | `PulseAnimation` (shared modifier driving all pulses via `TimelineView`) |

## Quick recipes

### Liquid Glass

```swift
Text("GPS locked")
    .padding()
    .clipShape(.rect(cornerRadius: FogRadius.pill, style: .continuous))
    .fogGlass(level: .control)     // .control / .hud / .tabBar
```

### Primary button

```swift
Button("Start Ride", action: startRide)
    .buttonStyle(.fogPrimary)
```

### HUD with four metrics

```swift
GlassHUDCard {
    MetricCell4Grid(cells: [
        .init(value: "18.3", label: "km/h"),
        .init(value: "342",  label: "hex", valueColor: .fogAccent),
        .init(value: "1:23", label: "moving"),
        .init(value: "+47",  label: "elev", valueColor: .fogGreen),
    ])
}
```

### Floating tab bar

```swift
NavigationStack { MapScreen() }
    .safeAreaInset(edge: .bottom) {
        FloatingGlassTabBar(selection: $selectedTab, items: tabs)
    }
```

### Fog-of-war hex

```swift
HexCell(state: .newUnlock, radius: 24)   // .fog / .visitedFaded / .explored / .newUnlock
```

## Fonts (DM Sans + IBM Plex Mono)

The registrar auto-runs on the first access of any `Font.fog*` accessor:

```swift
public static let ensureRegistered: Void = { register() }()
```

If the `.ttf` files are missing from `Sources/DesignSystem/Resources/Fonts/`
the registrar logs a DEBUG warning and every FogRide font accessor silently
falls back to the appropriate system font (SF Pro / SF Mono). **Drop the
files in before shipping** — see `Resources/Fonts/README.md`.

## Preview gallery

Embed `DesignSystemGallery` anywhere to visually verify tokens and components
side-by-side. Intended use: a lightweight gallery app target (add later in
Xcode UI by creating a new iOS app target and using `DesignSystemGallery()`
as the root view) or an `#Preview` block while iterating:

```swift
#Preview("Gallery") {
    NavigationStack { DesignSystemGallery() }
}
```

`.glassEffect` renders inconsistently in the Xcode preview canvas — run the
gallery on Simulator to verify glass appearance.

## Testing

```bash
cd Packages/DesignSystem && swift test
```

51 Swift Testing assertions across 13 suites cover token alphas, font
registration, hex geometry, pulse periods, and smoke-render checks on every
component via `ImageRenderer`.

## Conventions

- Swift 6.2, strict concurrency (`swiftLanguageModes: [.v6]` + upcoming
  features `NonisolatedNonsendingByDefault` + `InferIsolatedConformances`).
- iOS 26 + macOS 26 platforms (macOS is needed for `swift build` on CLI —
  the package is still intended for iOS consumption).
- SwiftUI only. No UIKit. No Observable-Object / @Published / GCD.
- All pulse animations run via `TimelineView(.animation)` — no `Timer`.
- Modifiers ship as `extension View` methods (`fogGlass`, `fogPulse`,
  `fogHexGlow`, `fogShadow`). Button styles ship as concrete types with
  static-member shortcuts (`.fogPrimary`, `.fogSecondary`, `.fogLink`).
- All public Sendable types conform explicitly.

## Not in this package

- Domain types (`Trip`, `User`, `Ride`) — those live in the FogRide domain
  layer. DesignSystem knows nothing about routes, rides, or users.
- Light theme — deferred to V2. Dark-only for now; all tokens assume
  `.preferredColorScheme(.dark)` at the root of the app.
- Snapshot-test baselines — intentionally deferred until CI has screenshot
  infrastructure. Current test suite uses `ImageRenderer` smoke checks.

## Roadmap link

Built as the F.3 task of Phase F (Foundation) for the RideVerse 18-month
solo-dev roadmap. See `Roadmap/Phase F — Foundation.md` for the goal and
acceptance criteria, and `Jira SCRUM-18` for the DoD history.

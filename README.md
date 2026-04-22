# RideVerse

iOS 26+ bicycle tracking app with a fog-of-war exploration mechanic over an H3 hexagonal grid. Codename **FogRide**. Solo developer, 18-month roadmap.

## Tech stack

- SwiftUI, Swift 6.2 (strict concurrency, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- SwiftData + CloudKit (metadata), GRDB 7 (time-series GPS)
- MapLibre Native + PMTiles
- [SwiftyH3](https://github.com/airbnb/h3) for hex cells
- AsyncBluetooth for BLE sensors (HR, power, cadence)
- Liquid Glass (iOS 26 `.glassEffect()`)

## Build

Open `RideVerse.xcworkspace` in **Xcode 26.4.1 or later**. Deployment target: iOS 26.

```
open RideVerse.xcworkspace
```

Single app target (`RideVerse`, bundle ID `com.iiiivaska.RideVerse`) plus local SPM packages under `Packages/`.

## Architecture

Three layers, dependencies flow top-down:

```
App (composition root)
  → Features (Recording, FogMap, TripDetail, TripList, Stats, Settings, Onboarding)
    → Domain (FogRideModels, FogRidePersistence, FogRideServices)
      → Packages (reusable SPM — no FogRide domain knowledge)
```

Packages never reference domain types (`Trip`, `User`, `Achievement`). They operate on primitives: `CLLocation`, `H3Index`, `[CLLocationCoordinate2D]`. Roughly half of the code is designed for reuse in future apps.

## Phase 0 SPM packages (current scaffolding)

| Package | Products | Purpose |
|---------|----------|---------|
| `HexKit` | `HexCore`, `HexGeometry` | Type-safe H3 wrapper, compaction, multipolygon geometry |
| `MapVerse` | `MapCore`, `MapFogOfWar` | MapLibre SwiftUI wrapper + fog-of-war inverted polygon layer |
| `LocationKit` | `LocationRecording` | GPS recording pipeline (adds filtering/analysis/motion in later phases) |
| `DesignSystem` | `DesignSystem` | Liquid Glass tokens and components (populated in SCRUM-18) |
| `PersistenceCore` | `PersistenceCore` | GRDB 7 setup with WAL and migrations (populated in SCRUM-20) |

Additional 13 packages (MapOverlays, MapOfflineRegions, LocationFiltering, LocationAnalysis, LocationMotion, BLESensorCore, CyclingSensors, WorkoutKit, TrackExport, plus Domain-layer libraries) are added through Phases 1–5 as they become needed.

## Documentation

The authoritative project documentation lives in the Obsidian vault at the repo root.

- **[Dashboard.md](Dashboard.md)** — entry point, navigation across all sections
- **[Architecture/](Architecture/)** — 18-package specs, rules, anti-patterns
- **[Design/](Design/)** — design system, 10 screen specs, screenshots, HTML prototype
- **[Roadmap/](Roadmap/)** — 7 phases (F → 5), goals, go/no-go criteria, Jira links

Tasks are tracked in **Jira project SCRUM** (`rideverse.atlassian.net`). Obsidian holds context and cross-references, not task state.

## Contributing / conventions

- `AGENTS.md` — full Swift/SwiftUI conventions for AI assistants and humans alike
- `CLAUDE.md` — guidance for Claude Code sessions
- Modern APIs only: `@Observable`, `NavigationStack`, `Tab`, `FormatStyle`, `foregroundStyle()`
- No GCD — concurrency via async/await
- No UIKit unless explicitly required

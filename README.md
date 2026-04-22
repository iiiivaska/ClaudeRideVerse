# TraVerse (repo: RideVerse)

[![CI](https://github.com/iiiivaska/ClaudeRideVerse/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/iiiivaska/ClaudeRideVerse/actions/workflows/ci.yml)

iOS 26+ bicycle tracking app with a fog-of-war exploration mechanic over an H3 hexagonal grid. App Store identity: **TraVerse**. Repo / Xcode project codename: **RideVerse** (historical, kept for git + CloudKit linkage). Previous codename: FogRide. Solo developer, 18-month roadmap.

Phase 0 (Prototype) ✅ complete — TestFlight build 1.1 submitted 2026-04-22. Currently in **Phase 1 — MVP** (0 / 19 tasks).

## Tech stack

- SwiftUI, Swift 6.2 (strict concurrency, `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`)
- SwiftData + CloudKit (metadata), GRDB 7 (time-series GPS)
- MapLibre Native + PMTiles
- [SwiftyH3](https://github.com/airbnb/h3) for hex cells
- AsyncBluetooth for BLE sensors (HR, power, cadence)
- Liquid Glass (iOS 26 `.glassEffect()`)

## Build

Open `RideVerse.xcworkspace` in **Xcode 26.4.1 or later**. Deployment target: iOS 26.

```bash
# First-time setup: create Secrets.xcconfig from example + fill in STADIA_API_KEY
cp RideVerse/Secrets.xcconfig.example RideVerse/Secrets.xcconfig
# edit RideVerse/Secrets.xcconfig and paste your Stadia API key

open RideVerse.xcworkspace
```

Single app target (`RideVerse` scheme, bundle ID `com.iiiivaska.TraVerse`, display name **TraVerse**) plus local SPM packages under `Packages/`.

`RideVerse/Secrets.xcconfig` is gitignored. CI generates a placeholder automatically — from a `STADIA_API_KEY` GitHub Actions secret if configured, or a no-tiles fallback otherwise.

## CI

[`ci.yml`](.github/workflows/ci.yml) runs on every push to `main` and every pull request against `main`. Two jobs on `macos-15`:

- **SPM tests** — matrix over all 5 packages, each runs `swift test` (host macOS, no simulator needed).
- **App target compiles** — `xcodebuild build` for the `RideVerse` scheme against a generic iOS Simulator.

Running package tests on host macOS is intentional: tests in this project exercise pure Swift logic, not iOS-only APIs. A full `xcodebuild test` through the workspace scheme is not used because Xcode 26's test-plan CLI loading is currently unreliable for workspaces with SPM test targets; `swift test` in each package is both faster and more deterministic.

TestFlight auto-deploy, SwiftLint, and performance benchmarks are tracked as follow-up tickets and are not part of this workflow.

### Local verification

Reproduce the CI pipeline locally before pushing:

```bash
# SPM tests — matches CI test-packages matrix
for p in HexKit MapVerse LocationKit DesignSystem PersistenceCore; do
  (cd "Packages/$p" && swift test) || break
done

# App target compiles — matches CI build-app job
xcodebuild build \
  -workspace RideVerse.xcworkspace \
  -scheme RideVerse \
  -destination 'generic/platform=iOS Simulator' \
  -skipPackagePluginValidation \
  -skipMacroValidation \
  CODE_SIGNING_ALLOWED=NO
```

For day-to-day development, the Xcode UI path works too: open `RideVerse.xcworkspace`, pick scheme `RideVerse`, ⌘U. The scheme has a shared test plan with all 7 test bundles.

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

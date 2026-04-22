# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

RideVerse (codename: FogRide) is an iOS 26+ bicycle tracking app with a fog-of-war exploration mechanic built on H3 hexagonal grids. Solo developer, 18-month roadmap. Currently in early architecture/scaffolding phase.

**Tech stack:** SwiftUI, Swift 6.2, SwiftData + CloudKit, MapLibre, SwiftyH3, GRDB, AsyncBluetooth, Liquid Glass design.

## Build & Run

- Open `RideVerse.xcworkspace` in Xcode 26.4.1+
- Single target: `RideVerse` (iOS app, deployment target 26.0)
- Bundle ID: `com.iiiivaska.RideVerse`
- No external dependency manager yet — pure native build
- If SwiftLint is installed, ensure zero warnings/errors before committing

### Xcode MCP Tools

When the Xcode MCP is available, prefer these over generic alternatives:
- `BuildProject` to verify compilation after changes
- `GetBuildLog` / `XcodeListNavigatorIssues` for build errors
- `RenderPreview` for visual SwiftUI verification
- `DocumentationSearch` to verify API availability
- `XcodeRead` / `XcodeWrite` / `XcodeUpdate` for project files

## Architecture

### Three-Layer Structure (dependencies flow top → down only)

```
App (composition root)
  → Features (RecordingFeature, FogMapFeature, TripDetailFeature, TripListFeature, StatsFeature, SettingsFeature, OnboardingFeature)
    → Domain (FogRideModels, FogRidePersistence, FogRideServices)
      → Packages (reusable SPM packages — no FogRide domain knowledge)
```

### Reusable SPM Packages (18 targets planned)

| Group | Packages | Purpose |
|-------|----------|---------|
| MapVerse | MapCore, MapOverlays, MapFogOfWar, MapOfflineRegions | MapLibre SwiftUI wrapper, overlays, fog rendering, PMTiles offline |
| LocationKit | LocationRecording, LocationFiltering, LocationAnalysis, LocationMotion | GPS recording, Kalman/DP filtering, metrics, auto-pause |
| HexKit | HexCore, HexGeometry | Type-safe H3 wrapper, compaction/multipolygon algorithms |
| SensorKit | BLESensorCore, CyclingSensors | BLE management, HR/Power/Cadence parsing |
| Other | WorkoutKit, TrackExport, PersistenceCore, DesignSystem | HealthKit, GPX/FIT, GRDB helpers, design tokens |

### Key Architecture Rules

1. **Packages never reference domain types** (`Trip`, `User`, `Ride`, `Achievement`). They operate on primitives: `CLLocation`, `H3Index`, `[CLLocationCoordinate2D]`.
2. **Packages don't know about app UI.** They may provide SwiftUI views, but styling comes from environment/modifiers, not hardcoded app colors.
3. **No dependency cycles.** Feature modules can depend on multiple packages, but packages don't depend on each other without strong justification.
4. **~50% of code** (MapVerse, LocationKit, HexKit, SensorKit) is designed for reuse in future apps.

## Swift & SwiftUI Conventions

Full details in `AGENTS.md`. Critical points:

- **Strict Swift concurrency** — `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` is enabled project-wide
- **`@Observable` only** — never use `ObservableObject`/`@Published`/`@StateObject`/`@ObservedObject`
- **Modern APIs only** — `FormatStyle` (not `DateFormatter`), `foregroundStyle()` (not `foregroundColor()`), `NavigationStack` (not `NavigationView`), `Tab` API (not `tabItem()`), `containerRelativeFrame()` over `GeometryReader`
- **No GCD** — all concurrency via async/await
- **No UIKit** unless explicitly requested

## SwiftData + CloudKit Rules

When SwiftData uses CloudKit sync:
- Never use `@Attribute(.unique)`
- All properties must have defaults or be optional
- All relationships must be optional

## Tooling & Workflow

- **Jira** — задачи и баг-трекинг. Используй Atlassian MCP tools (`searchJiraIssuesUsingJql`, `createJiraIssue`, `getJiraIssue` и др.)
- **Obsidian vault** — `.obsidian/` в корне проекта. Точка входа: `Dashboard.md`. Структура: `Architecture/`, `Design/`, `Roadmap/`, `Journal/`. Читай напрямую через Read, MCP не нужен
- **SwiftLint** — установлен (`swiftlint`). Zero warnings/errors перед коммитом
- **GitHub CLI** — `gh` для PR, issues, code review
- **Xcode MCP** — билд, превью, тесты, навигация (см. секцию Build & Run)
- **Pencil MCP** — дизайн `.pen` файлов. Только через pencil MCP tools, не Read/Grep

## Architecture Documentation

Вся проектная документация живёт в Obsidian vault (корень проекта):

- **`Dashboard.md`** — точка входа, навигация по всему vault
- **`Architecture/`** — спеки 18 пакетов, правила, антипаттерны
  - `_index.md` → `Обзор.md`, `MapVerse.md`, `LocationKit.md`, `HexKit.md`, `SensorKit.md`, `Domain.md`, `Прочие пакеты.md`, `Антипаттерны.md`
- **`Design/`** — дизайн-система, спеки 10 экранов, скриншоты, HTML-прототип
  - `_index.md` → `Дизайн-система.md`, `Screens/*.md`, `Assets/`, `Prototype/`
- **`Roadmap/`** — фазы проекта, цели, go/no-go критерии, ссылки на Jira
  - `_index.md` → `Phase F — Foundation.md` ... `Phase 5 — Watch & BLE.md`

Заметки используют `[[wiki-links]]` для навигации. Задачи ведутся в Jira (проект SCRUM), в Obsidian только ссылки и контекст.

Это авторитетный источник для архитектурных решений.

## graphify

This project has a graphify knowledge graph at graphify-out/.

Rules:
- Before answering architecture or codebase questions, read graphify-out/GRAPH_REPORT.md for god nodes and community structure
- If graphify-out/wiki/index.md exists, navigate it instead of reading raw files
- For cross-module "how does X relate to Y" questions, prefer `graphify query "<question>"`, `graphify path "<A>" "<B>"`, or `graphify explain "<concept>"` over grep — these traverse the graph's EXTRACTED + INFERRED edges instead of scanning files
- After modifying code files in this session, run `graphify update .` to keep the graph current (AST-only, no API cost)

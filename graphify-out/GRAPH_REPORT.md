# Graph Report - .  (2026-04-22)

## Corpus Check
- 159 files · ~203,867 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 806 nodes · 1280 edges · 34 communities detected
- Extraction: 71% EXTRACTED · 29% INFERRED · 0% AMBIGUOUS · INFERRED: 370 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_HexCell Core & Hierarchy|HexCell Core & Hierarchy]]
- [[_COMMUNITY_Architecture & Antipatterns|Architecture & Antipatterns]]
- [[_COMMUNITY_DesignSystem Cards & Gallery|DesignSystem Cards & Gallery]]
- [[_COMMUNITY_HexCellSet & FogStyle|HexCellSet & FogStyle]]
- [[_COMMUNITY_Fog GeoJSON & MapFogOfWar|Fog GeoJSON & MapFogOfWar]]
- [[_COMMUNITY_Project Config & Conventions|Project Config & Conventions]]
- [[_COMMUNITY_TabBar Navigation|TabBar Navigation]]
- [[_COMMUNITY_PersistenceCore & GRDB|PersistenceCore & GRDB]]
- [[_COMMUNITY_Button Styles & Tests|Button Styles & Tests]]
- [[_COMMUNITY_HexGlow Animations|HexGlow Animations]]
- [[_COMMUNITY_LocationRecorder|LocationRecorder]]
- [[_COMMUNITY_Glass Primitives & Tokens|Glass Primitives & Tokens]]
- [[_COMMUNITY_HexBBox Geometry|HexBBox Geometry]]
- [[_COMMUNITY_HexGrid Illustration|HexGrid Illustration]]
- [[_COMMUNITY_MapCamera|MapCamera]]
- [[_COMMUNITY_MapContent Builder|MapContent Builder]]
- [[_COMMUNITY_UI Screen Designs|UI Screen Designs]]
- [[_COMMUNITY_Onboarding Components|Onboarding Components]]
- [[_COMMUNITY_FogUpdateThrottle|FogUpdateThrottle]]
- [[_COMMUNITY_HexResolution Tests|HexResolution Tests]]
- [[_COMMUNITY_Pentagon Cell Tests|Pentagon Cell Tests]]
- [[_COMMUNITY_Metrics Token Tests|Metrics Token Tests]]
- [[_COMMUNITY_App Entry Points|App Entry Points]]
- [[_COMMUNITY_Font Scale Tests|Font Scale Tests]]
- [[_COMMUNITY_Color Tokens|Color Tokens]]
- [[_COMMUNITY_MapCore Module Tests|MapCore Module Tests]]
- [[_COMMUNITY_DesignSystem Module|DesignSystem Module]]
- [[_COMMUNITY_LocationRecording Module|LocationRecording Module]]
- [[_COMMUNITY_PersistenceCore Module|PersistenceCore Module]]
- [[_COMMUNITY_README & CI|README & CI]]
- [[_COMMUNITY_Graph Report|Graph Report]]
- [[_COMMUNITY_WorkoutKit|WorkoutKit]]
- [[_COMMUNITY_TripList Feature|TripList Feature]]
- [[_COMMUNITY_Domain SwiftUI Antipattern|Domain SwiftUI Antipattern]]

## God Nodes (most connected - your core abstractions)
1. `HexCell` - 58 edges
2. `HexCellSet` - 38 edges
3. `HexResolution` - 25 edges
4. `LocationRecorder` - 23 edges
5. `MockLocationSource` - 17 edges
6. `LocationRecorderTests` - 16 edges
7. `MapCamera` - 13 edges
8. `HexCellSetTests` - 13 edges
9. `Design Documentation Index` - 13 edges
10. `MapBBox` - 12 edges

## Surprising Connections (you probably didn't know these)
- `CLAUDE.md Project Configuration` --semantically_similar_to--> `RideVerse (FogRide) iOS App`  [INFERRED] [semantically similar]
  CLAUDE.md → README.md
- `RideVerse (FogRide) iOS App` --semantically_similar_to--> `RideVerse Project Dashboard`  [INFERRED] [semantically similar]
  README.md → Dashboard.md
- `settingsRow()` --calls--> `Font`  [INFERRED]
  /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/DesignSystem/Sources/DesignSystem/Cards/GroupedCard.swift → /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/DesignSystem/Sources/DesignSystem/Tokens/Font+FogRide.swift
- `SCRUM-29: PrototypeApp — map + fog + Start/Stop` --implements--> `Map Screen (Main Tab)`  [INFERRED]
  Dashboard.md → Design/Screens/Map.md
- `SCRUM-29: PrototypeApp — map + fog + Start/Stop` --implements--> `Fog-of-War Exploration Mechanic`  [INFERRED]
  Dashboard.md → README.md

## Hyperedges (group relationships)
- **Recording User Flow (Map → Recording → Trip Summary)** — screen_map, screen_recording, screen_trip_summary, screen_live_activity [EXTRACTED 0.95]
- **Fog-of-War System (HexKit + MapVerse + Design Hex Cells)** — readme_hexkit_package, readme_mapverse_package, readme_fog_of_war_mechanic, design_system_hex_cells [INFERRED 0.90]
- **Coding Conventions (AGENTS.md + CLAUDE.md + Strict Concurrency)** — agents_md_conventions, claude_md_project_config, claude_md_strict_concurrency, agents_md_observable_only, agents_md_no_gcd [EXTRACTED 0.95]
- **18-Month Roadmap Sequence (F → 0 → 1 → 2 → 3 → 4/5)** — phase_f_foundation, phase_0_prototype, phase_1_mvp, phase_2_social, phase_3_backend, phase_4_poi_ai, phase_5_watch_ble [EXTRACTED 1.00]
- **Trip Recording Orchestration (TripRecorder coordinates packages)** — service_trip_recorder, pkg_locationrecording, pkg_locationfiltering, pkg_locationanalysis, pkg_hexgeometry, repo_trip_repository [EXTRACTED 1.00]
- **Fog-of-War Rendering Pipeline (hex → multipolygon → map layer)** — pkg_hexcore, pkg_hexgeometry, pkg_mapfogofwar, pkg_mapcore, concept_inverted_multipolygon, concept_adaptive_compaction [INFERRED 0.90]
- **Four Main Tab Screens** — map_screen_design, rides_screen_design, stats_screen_design, profile_screen_design [EXTRACTED 1.00]
- **Hex Gamification Loop across Screens** — map_screen_design, rides_screen_design, trip_detail_design, trip_summary_design, stats_screen_design, hex_metric_display [INFERRED 0.85]
- **Onboarding Flow Sequence** — onboarding_welcome_design, onboarding_permission_design, check_hex_animation [INFERRED 0.75]

## Communities

### Community 0 - "HexCell Core & Hierarchy"
Cohesion: 0.05
Nodes (15): HexCell, HexCellBatch, HexCellSet, HexCellSet, HexCellSet, HexCellSetCompactionTests, HexCellSetMultiPolygonTests, HexCellSetTests (+7 more)

### Community 1 - "Architecture & Antipatterns"
Cohesion: 0.04
Nodes (84): Antipattern: Feature Imports Feature, Antipattern: God Package FogRideKit, Antipattern: Package Imports Domain, Antipattern: @Query for GPS Points, Antipattern: View Calls Repository Directly, Architecture: Antipatterns, Architecture: CI, Architecture: Domain (+76 more)

### Community 2 - "DesignSystem Cards & Gallery"
Cohesion: 0.03
Nodes (33): CardsSmokeTests, ContentView, ButtonsSection, CardsSection, DesignSystemGallery, GalleryPage, HexSection, IndicatorsSection (+25 more)

### Community 3 - "HexCellSet & FogStyle"
Cohesion: 0.04
Nodes (30): Equatable, Error, FogStyle, HexCellSet, HexError, antimeridianCrossing, invalidCoordinate, pentagonEncountered (+22 more)

### Community 4 - "Fog GeoJSON & MapFogOfWar"
Cohesion: 0.06
Nodes (15): FogGeoJSONBuilder, FogLayer, FogResolutionPolicy, HexMultiPolygon, Polygon, MapBBox, MapContent, MapContentBuilderTests (+7 more)

### Community 5 - "Project Config & Conventions"
Cohesion: 0.07
Nodes (41): AGENTS.md Swift/SwiftUI Conventions, Convention: Modern APIs only (FormatStyle, NavigationStack, Tab), Convention: No GCD, async/await only, Convention: @Observable only, no ObservableObject, SwiftData CloudKit Rules (no unique, defaults, optional relationships), CLAUDE.md Project Configuration, Strict Swift Concurrency (MainActor default), Phase 0 — Prototype (current phase) (+33 more)

### Community 6 - "TabBar Navigation"
Cohesion: 0.06
Nodes (25): Comparable, FloatingGlassTabBar, FogTab, TabButton, FloatingGlassTabBarTests, HexResolution, r0, r1 (+17 more)

### Community 7 - "PersistenceCore & GRDB"
Cohesion: 0.1
Nodes (12): DatabaseProvider, Migration, buildMigrator(), Migration, DatabaseProvider, AddTimestampColumn, CreateItemsTable, DatabaseProviderTests (+4 more)

### Community 8 - "Button Styles & Tests"
Cohesion: 0.07
Nodes (14): ButtonsSmokeTests, ButtonStyle, Font, ButtonStyle, FogLinkButtonStyle, FogRadius, FogShadow, FogSpacing (+6 more)

### Community 9 - "HexGlow Animations"
Cohesion: 0.07
Nodes (13): DesignSystemGallerySmokeTests, HexGlowPulseExample, HexPathGeneratorExampleShape, View, IndicatorsSmokeTests, PulseAnimation, PulseStyle, accent (+5 more)

### Community 10 - "LocationRecorder"
Cohesion: 0.18
Nodes (6): LocationRecorder, DirectMockSource, LocationRecorderTests, makeLocation(), MockLocationSource, LocationSource

### Community 11 - "Glass Primitives & Tokens"
Cohesion: 0.07
Nodes (18): CaseIterable, CustomStringConvertible, GlassCircle, FogGlassLevel, control, hud, tabBar, FogGlassModifier (+10 more)

### Community 12 - "HexBBox Geometry"
Cohesion: 0.1
Nodes (4): HexBBox, HexBBoxTests, MapBBoxTests, MapStyleTests

### Community 13 - "HexGrid Illustration"
Cohesion: 0.12
Nodes (5): HexCellTests, HexGridIllustration, HexPathGenerator, approx(), HexPathGeneratorTests

### Community 14 - "MapCamera"
Cohesion: 0.11
Nodes (7): MapCamera, MapCameraTests, Coordinator, MapViewRepresentable, MLNMapViewDelegate, NSObject, UIViewRepresentable

### Community 15 - "MapContent Builder"
Cohesion: 0.18
Nodes (9): ConditionalMapContent, EmptyMapContent, MapContent, MapContentGroup, OptionalMapContent, Storage, first, second (+1 more)

### Community 16 - "UI Screen Designs"
Cohesion: 0.22
Nodes (15): Hex Grid Loading Animation (Prototype), Dark Theme Design Language, Eddington Number (E) Stat, Fog-of-War Hexagonal Overlay on Map, Hex Count as Core Gamification Metric, Map Screen - Fog-of-War Hex Map with Start Ride CTA, Onboarding Permission - Location Access Request, Onboarding Welcome - Discover Where You've Ridden (+7 more)

### Community 17 - "Onboarding Components"
Cohesion: 0.15
Nodes (6): OBIconContainer, Tone, accent, red, OnboardingDots, OnboardingTests

### Community 18 - "FogUpdateThrottle"
Cohesion: 0.39
Nodes (2): FogUpdateThrottle, FogUpdateThrottleTests

### Community 19 - "HexResolution Tests"
Cohesion: 0.29
Nodes (1): HexResolutionTests

### Community 20 - "Pentagon Cell Tests"
Cohesion: 0.52
Nodes (1): HexCellPentagonTests

### Community 21 - "Metrics Token Tests"
Cohesion: 0.33
Nodes (1): MetricsTests

### Community 22 - "App Entry Points"
Cohesion: 0.4
Nodes (3): App, DesignSystemGalleryApp, RideVerseApp

### Community 23 - "Font Scale Tests"
Cohesion: 0.5
Nodes (1): FontScaleTests

### Community 24 - "Color Tokens"
Cohesion: 0.67
Nodes (1): Color

### Community 25 - "MapCore Module Tests"
Cohesion: 0.67
Nodes (1): MapCoreModuleTests

### Community 27 - "DesignSystem Module"
Cohesion: 1.0
Nodes (1): DesignSystem

### Community 28 - "LocationRecording Module"
Cohesion: 1.0
Nodes (1): LocationRecording

### Community 29 - "PersistenceCore Module"
Cohesion: 1.0
Nodes (1): PersistenceCore

### Community 30 - "README & CI"
Cohesion: 1.0
Nodes (2): CI Pipeline (ci.yml), Rationale: SPM tests run on host macOS not simulator

### Community 41 - "Graph Report"
Cohesion: 1.0
Nodes (1): Graph Report

### Community 42 - "WorkoutKit"
Cohesion: 1.0
Nodes (1): WorkoutKit Package

### Community 43 - "TripList Feature"
Cohesion: 1.0
Nodes (1): TripListFeature

### Community 44 - "Domain SwiftUI Antipattern"
Cohesion: 1.0
Nodes (1): Antipattern: Domain Imports SwiftUI

## Knowledge Gaps
- **99 isolated node(s):** `DesignSystem`, `ButtonStyle`, `ButtonStyle`, `fog`, `visitedFaded` (+94 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `FogUpdateThrottle`** (9 nodes): `FogUpdateThrottle`, `.init()`, `.reset()`, `.shouldUpdate()`, `FogUpdateThrottleTests`, `.firstCallAllowsUpdate()`, `.immediateSecondCallBlocked()`, `.resetAllowsImmediateUpdate()`, `FogUpdateThrottle.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `HexResolution Tests`** (7 nodes): `HexResolutionTests`, `.allCasesHas16Resolutions()`, `.averageAreaR9()`, `.averageEdgeMetersR0()`, `.averageEdgeMetersR9()`, `.comparable()`, `.edgeLengthDecreasesWithResolution()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Pentagon Cell Tests`** (7 nodes): `HexCellPentagonTests`, `.constructR0Index()`, `.findPentagonsAtR0()`, `.pentagonBoundaryHas5Vertices()`, `.pentagonCountAtR0()`, `.pentagonHas5Neighbors()`, `.pentagonIsPentagon()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Metrics Token Tests`** (6 nodes): `MetricsTests`, `.accentGlowShadow()`, `.radiiValues()`, `.spacingMonotonic()`, `.tabBarDualShadow()`, `MetricsTests.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Font Scale Tests`** (4 nodes): `FontScaleTests`, `.monoScale()`, `.sansScale()`, `FontScaleTests.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Color Tokens`** (3 nodes): `Color`, `.init()`, `Color+FogRide.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `MapCore Module Tests`** (3 nodes): `MapCoreModuleTests`, `.moduleImportsSuccessfully()`, `MapCoreTests.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `DesignSystem Module`** (2 nodes): `DesignSystem`, `DesignSystem.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `LocationRecording Module`** (2 nodes): `LocationRecording`, `LocationRecording.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `PersistenceCore Module`** (2 nodes): `PersistenceCore`, `PersistenceCore.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `README & CI`** (2 nodes): `CI Pipeline (ci.yml)`, `Rationale: SPM tests run on host macOS not simulator`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Graph Report`** (1 nodes): `Graph Report`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `WorkoutKit`** (1 nodes): `WorkoutKit Package`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `TripList Feature`** (1 nodes): `TripListFeature`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Domain SwiftUI Antipattern`** (1 nodes): `Antipattern: Domain Imports SwiftUI`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `HexCell` connect `Glass Primitives & Tokens` to `DesignSystem Cards & Gallery`, `HexCellSet & FogStyle`, `TabBar Navigation`?**
  _High betweenness centrality (0.137) - this node is a cross-community bridge._
- **Why does `HexCell` connect `HexCell Core & Hierarchy` to `Pentagon Cell Tests`, `HexGrid Illustration`?**
  _High betweenness centrality (0.085) - this node is a cross-community bridge._
- **Why does `HexBBox` connect `HexBBox Geometry` to `HexCell Core & Hierarchy`, `HexCellSet & FogStyle`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Are the 53 inferred relationships involving `HexCell` (e.g. with `.allStatesRender()` and `makeCellSet()`) actually correct?**
  _`HexCell` has 53 INFERRED edges - model-reasoned connections that need verification._
- **Are the 36 inferred relationships involving `HexCellSet` (e.g. with `makeCellSet()` and `.emptyVisitedCellsProduceFullFog()`) actually correct?**
  _`HexCellSet` has 36 INFERRED edges - model-reasoned connections that need verification._
- **What connects `DesignSystem`, `ButtonStyle`, `ButtonStyle` to the rest of the system?**
  _99 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `HexCell Core & Hierarchy` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
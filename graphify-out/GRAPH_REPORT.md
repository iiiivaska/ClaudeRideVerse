# Graph Report - .  (2026-04-22)

## Corpus Check
- 155 files · ~144,655 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 847 nodes · 1153 edges · 91 communities detected
- Extraction: 72% EXTRACTED · 28% INFERRED · 0% AMBIGUOUS · INFERRED: 321 edges (avg confidence: 0.8)
- Token cost: 48,800 input · 15,320 output

## Community Hubs (Navigation)
- [[_COMMUNITY_DesignSystem Cards & Gallery|DesignSystem Cards & Gallery]]
- [[_COMMUNITY_HexKit Cell Hierarchy & Sets|HexKit Cell Hierarchy & Sets]]
- [[_COMMUNITY_Fog Style & Error Types|Fog Style & Error Types]]
- [[_COMMUNITY_Project Architecture & CI|Project Architecture & CI]]
- [[_COMMUNITY_Liquid Glass System|Liquid Glass System]]
- [[_COMMUNITY_HexBBox & Viewport Tests|HexBBox & Viewport Tests]]
- [[_COMMUNITY_PersistenceCore GRDB Stack|PersistenceCore GRDB Stack]]
- [[_COMMUNITY_FogLayer & MapBBox|FogLayer & MapBBox]]
- [[_COMMUNITY_Button Styles & Tests|Button Styles & Tests]]
- [[_COMMUNITY_Fog GeoJSON & Compaction|Fog GeoJSON & Compaction]]
- [[_COMMUNITY_Hex Illustration UI|Hex Illustration UI]]
- [[_COMMUNITY_MapCamera & Tests|MapCamera & Tests]]
- [[_COMMUNITY_HexResolution Levels|HexResolution Levels]]
- [[_COMMUNITY_Product Roadmap & Features|Product Roadmap & Features]]
- [[_COMMUNITY_Hex Glow Pulse Animations|Hex Glow Pulse Animations]]
- [[_COMMUNITY_MapContent Builder Protocol|MapContent Builder Protocol]]
- [[_COMMUNITY_Onboarding Components|Onboarding Components]]
- [[_COMMUNITY_iOS Prototype JSX Frame|iOS Prototype JSX Frame]]
- [[_COMMUNITY_FogUpdateThrottle Actor|FogUpdateThrottle Actor]]
- [[_COMMUNITY_Profile Screen UI|Profile Screen UI]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 23|Community 23]]
- [[_COMMUNITY_Community 24|Community 24]]
- [[_COMMUNITY_Community 25|Community 25]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 29|Community 29]]
- [[_COMMUNITY_Community 30|Community 30]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 33|Community 33]]
- [[_COMMUNITY_Community 34|Community 34]]
- [[_COMMUNITY_Community 35|Community 35]]
- [[_COMMUNITY_Community 36|Community 36]]
- [[_COMMUNITY_Community 37|Community 37]]
- [[_COMMUNITY_Community 38|Community 38]]
- [[_COMMUNITY_Community 39|Community 39]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 43|Community 43]]
- [[_COMMUNITY_Community 45|Community 45]]
- [[_COMMUNITY_Community 46|Community 46]]
- [[_COMMUNITY_Community 47|Community 47]]
- [[_COMMUNITY_Community 48|Community 48]]
- [[_COMMUNITY_Community 49|Community 49]]
- [[_COMMUNITY_Community 50|Community 50]]
- [[_COMMUNITY_Community 51|Community 51]]
- [[_COMMUNITY_Community 52|Community 52]]
- [[_COMMUNITY_Community 53|Community 53]]
- [[_COMMUNITY_Community 54|Community 54]]
- [[_COMMUNITY_Community 55|Community 55]]
- [[_COMMUNITY_Community 66|Community 66]]
- [[_COMMUNITY_Community 67|Community 67]]
- [[_COMMUNITY_Community 68|Community 68]]
- [[_COMMUNITY_Community 69|Community 69]]
- [[_COMMUNITY_Community 70|Community 70]]
- [[_COMMUNITY_Community 71|Community 71]]
- [[_COMMUNITY_Community 72|Community 72]]
- [[_COMMUNITY_Community 73|Community 73]]
- [[_COMMUNITY_Community 74|Community 74]]
- [[_COMMUNITY_Community 75|Community 75]]
- [[_COMMUNITY_Community 76|Community 76]]
- [[_COMMUNITY_Community 77|Community 77]]
- [[_COMMUNITY_Community 78|Community 78]]
- [[_COMMUNITY_Community 79|Community 79]]
- [[_COMMUNITY_Community 80|Community 80]]
- [[_COMMUNITY_Community 81|Community 81]]
- [[_COMMUNITY_Community 82|Community 82]]
- [[_COMMUNITY_Community 83|Community 83]]
- [[_COMMUNITY_Community 84|Community 84]]
- [[_COMMUNITY_Community 85|Community 85]]
- [[_COMMUNITY_Community 86|Community 86]]
- [[_COMMUNITY_Community 87|Community 87]]
- [[_COMMUNITY_Community 88|Community 88]]
- [[_COMMUNITY_Community 89|Community 89]]
- [[_COMMUNITY_Community 90|Community 90]]
- [[_COMMUNITY_Community 91|Community 91]]
- [[_COMMUNITY_Community 92|Community 92]]
- [[_COMMUNITY_Community 93|Community 93]]
- [[_COMMUNITY_Community 94|Community 94]]
- [[_COMMUNITY_Community 95|Community 95]]
- [[_COMMUNITY_Community 96|Community 96]]
- [[_COMMUNITY_Community 97|Community 97]]
- [[_COMMUNITY_Community 98|Community 98]]
- [[_COMMUNITY_Community 99|Community 99]]
- [[_COMMUNITY_Community 100|Community 100]]
- [[_COMMUNITY_Community 101|Community 101]]
- [[_COMMUNITY_Community 102|Community 102]]

## God Nodes (most connected - your core abstractions)
1. `HexCell` - 58 edges
2. `HexCellSet` - 38 edges
3. `HexResolution` - 25 edges
4. `LocationRecorder` - 14 edges
5. `MapCamera` - 13 edges
6. `HexCellSetTests` - 13 edges
7. `MapBBox` - 12 edges
8. `HexCellHierarchyTests` - 12 edges
9. `HexCell` - 11 edges
10. `HexMultiPolygon` - 11 edges

## Surprising Connections (you probably didn't know these)
- `HexCellSet+ViewportCulling` --references--> `HexCell`  [EXTRACTED]
  Packages/HexKit/Sources/HexGeometry/HexCellSet+ViewportCulling.swift → /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/HexKit/Sources/HexCore/HexCell.swift
- `HexCellSet+Compaction` --references--> `HexCellSet`  [EXTRACTED]
  Packages/HexKit/Sources/HexGeometry/HexCellSet+Compaction.swift → /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/HexKit/Sources/HexGeometry/HexCellSet.swift
- `MapFogOfWar Module` --references--> `FogStyle`  [EXTRACTED]
  Packages/MapVerse/Sources/MapFogOfWar/MapFogOfWar.swift → /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/MapVerse/Sources/MapFogOfWar/FogStyle.swift
- `FogGeoJSONBuilder` --references--> `HexKit Package`  [EXTRACTED]
  /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/MapVerse/Sources/MapFogOfWar/FogGeoJSONBuilder.swift → Packages/HexKit/Package.swift
- `MapFogOfWar Module` --references--> `FogUpdateThrottle`  [EXTRACTED]
  Packages/MapVerse/Sources/MapFogOfWar/MapFogOfWar.swift → /Users/iiiivaska/Developer/ClaudeRideVerse/Packages/MapVerse/Sources/MapFogOfWar/FogUpdateThrottle.swift

## Hyperedges (group relationships)
- **Liquid Glass UI Pattern** — ios_frame_iosglaspill, ios_frame_liquid_glass, designsystem_package [INFERRED 0.85]
- **Liquid Glass Rendering System** — fogglasslevel_enum, glasshudcard_view, glasspill_view, glasscircle_view, floatingglasstabbar_view [INFERRED 0.92]
- **Metric Display Stack** — monoval_view, monolabel_view, metriccell4grid_view, statcard2x2_view [INFERRED 0.90]
- **MapCore SwiftUI Wrapper** — mapview_struct, mapcamera_struct, mapstyle_struct, mapcontentbuilder_enum, mapviewrepresentable_struct [EXTRACTED 1.00]
- **Fog-of-War Rendering Pipeline** — foggeojsonbuilder_foggeojsonbuilder, fogupdatethrottle_fogupdatethrottle, fogstyle_fogstyle [INFERRED 0.90]
- **Location Recording Pipeline** — locationsource_locationsource, recordingconfiguration_recordingconfiguration, locationrecorder_locationrecorder, rawlocation_rawlocation, recordingstate_recordingstate [INFERRED 0.85]
- **HexKit Geometry Pipeline** — hexcellset_hexcellset, hexcellset_compaction, hexcellset_multipolygon, hexmultipolygon_hexmultipolygon [INFERRED 0.90]
- **PersistenceCore GRDB Stack** — persistencecore_module, databaseprovider_databaseprovider, migration_migration, observation_async, grdb_dependency [EXTRACTED 1.00]
- **Design System Governs All Screens** — design_system_spec, screen_map, screen_recording, screen_stats, screen_trip_detail, screen_rides, screen_trip_summary, screen_onboarding, screen_profile [EXTRACTED 1.00]
- **Architecture Rules System** — three_layer_architecture, package_no_domain_rule, swift_concurrency_rules, observable_pattern, swiftdata_cloudkit_rules [EXTRACTED 1.00]
- **Fog of War Rendering Pipeline** —  [INFERRED 1.00]
- **Trip Recording Orchestration** —  [INFERRED 1.00]
- **Dual Storage Strategy** —  [INFERRED 1.00]

## Communities

### Community 0 - "DesignSystem Cards & Gallery"
Cohesion: 0.03
Nodes (34): CardsSmokeTests, ContentView, ButtonsSection, CardsSection, DesignSystemGallery, GalleryPage, HexSection, IndicatorsSection (+26 more)

### Community 1 - "HexKit Cell Hierarchy & Sets"
Cohesion: 0.06
Nodes (12): HexCell, HexCellSet, HexCellSet, HexCellSet, HexCellSetCompactionTests, HexCellSetMultiPolygonTests, HexCellSetTests, HexCellHierarchyTests (+4 more)

### Community 2 - "Fog Style & Error Types"
Cohesion: 0.05
Nodes (33): Equatable, Error, FogStyle, HexError, antimeridianCrossing, invalidCoordinate, pentagonEncountered, resolutionMismatch (+25 more)

### Community 3 - "Project Architecture & CI"
Cohesion: 0.05
Nodes (47): H3 Adaptive Compaction, Inverted MultiPolygon GeoJSON, Antipattern: @Query for GPS points, CI — GitHub Actions, Liquid Glass Design System, FogRidePersistence, FogRideServices, SCRUM-17 CI GitHub Actions (+39 more)

### Community 4 - "Liquid Glass System"
Cohesion: 0.05
Nodes (25): CaseIterable, CustomStringConvertible, FogGlassLevel, control, hud, tabBar, FogGlassModifier, View (+17 more)

### Community 5 - "HexBBox & Viewport Tests"
Cohesion: 0.08
Nodes (7): HexBBox, HexBBoxTests, HexCellSet+ViewportCulling, HexCellSet, HexCellSetViewportTests, MapBBoxTests, MapStyleTests

### Community 6 - "PersistenceCore GRDB Stack"
Cohesion: 0.09
Nodes (15): DatabaseProvider, GRDB, Migration, buildMigrator(), Migration, Observation+Async, DatabaseProvider, PersistenceCore Module (+7 more)

### Community 7 - "FogLayer & MapBBox"
Cohesion: 0.08
Nodes (12): FogLayer, FogResolutionPolicy, MapBBox, MapContent, MapContentBuilderTests, TestContent, FogLayerTests, FogResolutionPolicyTests (+4 more)

### Community 8 - "Button Styles & Tests"
Cohesion: 0.06
Nodes (15): ButtonsSmokeTests, ButtonStyle, Font, settingsRow(), ButtonStyle, FogLinkButtonStyle, FogRadius, FogShadow (+7 more)

### Community 9 - "Fog GeoJSON & Compaction"
Cohesion: 0.11
Nodes (10): FogGeoJSONBuilder, HexCellBatch, HexCellSet+Compaction, HexCellSet+MultiPolygon, HexCellBatchTests, HexKit Package, HexMultiPolygon, Polygon (+2 more)

### Community 10 - "Hex Illustration UI"
Cohesion: 0.12
Nodes (5): HexCellTests, HexGridIllustration, HexPathGenerator, approx(), HexPathGeneratorTests

### Community 11 - "MapCamera & Tests"
Cohesion: 0.11
Nodes (7): MapCamera, MapCameraTests, Coordinator, MapViewRepresentable, MLNMapViewDelegate, NSObject, UIViewRepresentable

### Community 12 - "HexResolution Levels"
Cohesion: 0.1
Nodes (19): Comparable, HexResolution, r0, r1, r10, r11, r12, r13 (+11 more)

### Community 13 - "Product Roadmap & Features"
Cohesion: 0.12
Nodes (18): Dual Write Migration Strategy, k-anonymity Heatmap Privacy, Collaborative Fog Mode, Fog of War mechanic, Global Heatmap with k-anonymity, Maximum Fog Unlock Route Planner, Nearby Riders Mode, Phase 0 — Prototype (+10 more)

### Community 14 - "Hex Glow Pulse Animations"
Cohesion: 0.13
Nodes (6): DesignSystemGallerySmokeTests, HexGlowPulseExample, HexPathGeneratorExampleShape, View, IndicatorsSmokeTests, Shape

### Community 15 - "MapContent Builder Protocol"
Cohesion: 0.18
Nodes (9): ConditionalMapContent, EmptyMapContent, MapContent, MapContentGroup, OptionalMapContent, Storage, first, second (+1 more)

### Community 16 - "Onboarding Components"
Cohesion: 0.15
Nodes (6): OBIconContainer, Tone, accent, red, OnboardingDots, OnboardingTests

### Community 17 - "iOS Prototype JSX Frame"
Cohesion: 0.25
Nodes (5): IOSDevice(), IOSGlassPill, IOSNavBar(), IOSStatusBar(), Liquid Glass Design (iOS 26)

### Community 18 - "FogUpdateThrottle Actor"
Cohesion: 0.39
Nodes (2): FogUpdateThrottle, FogUpdateThrottleTests

### Community 19 - "Profile Screen UI"
Cohesion: 0.25
Nodes (8): Auto-Pause Toggle, Show Direction to Fog Toggle, Freemium Model, Haptic on Hex Unlock Toggle, Recording Settings Section, Profile Screen, Free Tier Upgrade Banner, User Identity Section

### Community 20 - "Community 20"
Cohesion: 0.29
Nodes (1): HexResolutionTests

### Community 21 - "Community 21"
Cohesion: 0.33
Nodes (1): MetricsTests

### Community 22 - "Community 22"
Cohesion: 0.33
Nodes (4): @Observable Pattern Rule, Packages Never Reference Domain Types, Swift Concurrency Rules, Three-Layer Architecture

### Community 23 - "Community 23"
Cohesion: 0.33
Nodes (6): Antipattern: Domain imports SwiftUI, Antipattern: Feature imports Feature, Antipattern: Package imports Domain, Antipattern: View accesses Repository directly, Three-Layer Architecture, Rationale: 18 SPM targets not monolith

### Community 24 - "Community 24"
Cohesion: 0.33
Nodes (6): Active Explored Hex Cells, Fog of War Hex Mechanic, Hex Grid Check Screen, H3 Hexagonal Grid Cluster, Inactive Unexplored Hex Cells, Neon Glow Visual Style

### Community 25 - "Community 25"
Cohesion: 0.33
Nodes (6): City Exploration Label, Fog-of-War Hex Overlay, Location Indicator, Map Screen, Start Ride Button, Stats Bar

### Community 26 - "Community 26"
Cohesion: 0.33
Nodes (6): View/Share/Discard Actions, Ride Complete Checkmark, Elevation Line Chart, Personal Best Banner, Trip Summary Screen, 2x2 Stats Card

### Community 27 - "Community 27"
Cohesion: 0.33
Nodes (6): Allow Location Access Button, Show Your Rides on the Map, Location Pin Icon, On-Device Privacy Message, Onboarding Permission Screen, Not Now Skip Button

### Community 28 - "Community 28"
Cohesion: 0.4
Nodes (3): App, DesignSystemGalleryApp, RideVerseApp

### Community 29 - "Community 29"
Cohesion: 0.6
Nodes (5): Font+FogRide Tokens, MetricCell4Grid, MonoLabel, MonoVal, StatCard2x2

### Community 30 - "Community 30"
Cohesion: 0.4
Nodes (5): MapCamera, MapContentBuilder, MapStyle, MapView, MapViewRepresentable

### Community 31 - "Community 31"
Cohesion: 0.4
Nodes (5): Eddington Number, Hex Metrics Section, Map Preview Thumbnail, Stats Screen, Segmented Time Filter

### Community 32 - "Community 32"
Cohesion: 0.4
Nodes (5): 4-Step Onboarding Flow, Get Started Button, Discover Where You've Ridden, Hex Cluster Illustration, Onboarding Welcome Screen

### Community 33 - "Community 33"
Cohesion: 0.4
Nodes (5): Fog-of-War Route Overlay, Hex Stat (+47 / 1284), Route Map Preview, Trip Detail Screen, 2x2 Stats Grid

### Community 34 - "Community 34"
Cohesion: 0.4
Nodes (5): Hex Gain Badge (+N hex), Ride Cell with Map Thumbnail, Rides Screen, Timeline Grouped Ride List, Weekly Summary Banner

### Community 35 - "Community 35"
Cohesion: 0.5
Nodes (1): FontScaleTests

### Community 36 - "Community 36"
Cohesion: 0.67
Nodes (4): FogGlassLevel, GlassCircle, GlassHUDCard, GlassPill

### Community 37 - "Community 37"
Cohesion: 0.5
Nodes (4): FogLayer, FogResolutionPolicy, MapContent Protocol, VisitedCells Protocol

### Community 38 - "Community 38"
Cohesion: 0.67
Nodes (1): Color

### Community 39 - "Community 39"
Cohesion: 0.67
Nodes (1): MapCoreModuleTests

### Community 40 - "Community 40"
Cohesion: 0.67
Nodes (2): Obsidian Vault, Obsidian Vault Organization Design Spec

### Community 41 - "Community 41"
Cohesion: 0.67
Nodes (3): BLESensorCore, CyclingSensors, AsyncBluetooth

### Community 43 - "Community 43"
Cohesion: 1.0
Nodes (1): DesignSystem

### Community 45 - "Community 45"
Cohesion: 1.0
Nodes (1): LocationRecording

### Community 46 - "Community 46"
Cohesion: 1.0
Nodes (1): PersistenceCore

### Community 47 - "Community 47"
Cohesion: 1.0
Nodes (2): ContentView, RideVerseApp

### Community 48 - "Community 48"
Cohesion: 1.0
Nodes (2): DesignSystem SPM Package, DesignSystemGalleryApp

### Community 49 - "Community 49"
Cohesion: 1.0
Nodes (2): HexGridIllustration, HexPathGenerator

### Community 50 - "Community 50"
Cohesion: 1.0
Nodes (2): LocationPulseRing, RecPulseDot

### Community 51 - "Community 51"
Cohesion: 1.0
Nodes (2): LocationKit Package, LocationRecording Module

### Community 52 - "Community 52"
Cohesion: 1.0
Nodes (2): Design System Spec, Liquid Glass Design

### Community 53 - "Community 53"
Cohesion: 1.0
Nodes (2): Screen: Recording, Screen: Trip Summary

### Community 54 - "Community 54"
Cohesion: 1.0
Nodes (2): Fog-of-War Exploration Mechanic, Screen: Map

### Community 55 - "Community 55"
Cohesion: 1.0
Nodes (2): FogRideModels, Trip (@Model)

### Community 66 - "Community 66"
Cohesion: 1.0
Nodes (1): FogPrimaryButtonStyle

### Community 67 - "Community 67"
Cohesion: 1.0
Nodes (1): FogLinkButtonStyle

### Community 68 - "Community 68"
Cohesion: 1.0
Nodes (1): StopButton

### Community 69 - "Community 69"
Cohesion: 1.0
Nodes (1): FogSecondaryButtonStyle

### Community 70 - "Community 70"
Cohesion: 1.0
Nodes (1): DesignSystemGallery

### Community 71 - "Community 71"
Cohesion: 1.0
Nodes (1): UpsellCard

### Community 72 - "Community 72"
Cohesion: 1.0
Nodes (1): FloatingGlassTabBar

### Community 73 - "Community 73"
Cohesion: 1.0
Nodes (1): Color+FogRide Tokens

### Community 74 - "Community 74"
Cohesion: 1.0
Nodes (1): FogSpacing

### Community 75 - "Community 75"
Cohesion: 1.0
Nodes (1): FogRadius

### Community 76 - "Community 76"
Cohesion: 1.0
Nodes (1): PulseAnimation

### Community 77 - "Community 77"
Cohesion: 1.0
Nodes (1): OBIconContainer

### Community 78 - "Community 78"
Cohesion: 1.0
Nodes (1): OnboardingDots

### Community 79 - "Community 79"
Cohesion: 1.0
Nodes (1): MapVerse Package

### Community 80 - "Community 80"
Cohesion: 1.0
Nodes (1): MapBBox

### Community 81 - "Community 81"
Cohesion: 1.0
Nodes (1): HexCell+Hierarchy

### Community 82 - "Community 82"
Cohesion: 1.0
Nodes (1): HexGeometry Module

### Community 83 - "Community 83"
Cohesion: 1.0
Nodes (1): RideVerse (FogRide)

### Community 84 - "Community 84"
Cohesion: 1.0
Nodes (1): Screen: Stats

### Community 85 - "Community 85"
Cohesion: 1.0
Nodes (1): Screen: Trip Detail

### Community 86 - "Community 86"
Cohesion: 1.0
Nodes (1): Screen: Rides

### Community 87 - "Community 87"
Cohesion: 1.0
Nodes (1): Screen: Onboarding

### Community 88 - "Community 88"
Cohesion: 1.0
Nodes (1): Screen: Profile

### Community 89 - "Community 89"
Cohesion: 1.0
Nodes (1): Screen: Paywall

### Community 90 - "Community 90"
Cohesion: 1.0
Nodes (1): Screen: Live Activity

### Community 91 - "Community 91"
Cohesion: 1.0
Nodes (1): SwiftData+CloudKit Rules

### Community 92 - "Community 92"
Cohesion: 1.0
Nodes (1): FogRide HTML Prototype

### Community 93 - "Community 93"
Cohesion: 1.0
Nodes (1): Archive Architecture Doc

### Community 94 - "Community 94"
Cohesion: 1.0
Nodes (1): Roadmap Index

### Community 95 - "Community 95"
Cohesion: 1.0
Nodes (1): MapOfflineRegions

### Community 96 - "Community 96"
Cohesion: 1.0
Nodes (1): LocationMotion

### Community 97 - "Community 97"
Cohesion: 1.0
Nodes (1): Antipattern: God-Package FogRideKit

### Community 98 - "Community 98"
Cohesion: 1.0
Nodes (1): Antipattern: DomainEvent with UI context

### Community 99 - "Community 99"
Cohesion: 1.0
Nodes (1): Live Activity + Dynamic Island

### Community 100 - "Community 100"
Cohesion: 1.0
Nodes (1): SCRUM-28 LocationRecording (prototype)

### Community 101 - "Community 101"
Cohesion: 1.0
Nodes (1): SCRUM-29 PrototypeApp

### Community 102 - "Community 102"
Cohesion: 1.0
Nodes (1): SCRUM-30 TestFlight + go/no-go

## Knowledge Gaps
- **149 isolated node(s):** `DesignSystem`, `ButtonStyle`, `ButtonStyle`, `fog`, `visitedFaded` (+144 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `FogUpdateThrottle Actor`** (9 nodes): `FogUpdateThrottle`, `.init()`, `.reset()`, `.shouldUpdate()`, `FogUpdateThrottleTests`, `.firstCallAllowsUpdate()`, `.immediateSecondCallBlocked()`, `.resetAllowsImmediateUpdate()`, `FogUpdateThrottle.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 20`** (7 nodes): `HexResolutionTests`, `.allCasesHas16Resolutions()`, `.averageAreaR9()`, `.averageEdgeMetersR0()`, `.averageEdgeMetersR9()`, `.comparable()`, `.edgeLengthDecreasesWithResolution()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 21`** (6 nodes): `MetricsTests`, `.accentGlowShadow()`, `.radiiValues()`, `.spacingMonotonic()`, `.tabBarDualShadow()`, `MetricsTests.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 35`** (4 nodes): `FontScaleTests`, `.monoScale()`, `.sansScale()`, `FontScaleTests.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 38`** (3 nodes): `Color`, `.init()`, `Color+FogRide.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 39`** (3 nodes): `MapCoreModuleTests`, `.moduleImportsSuccessfully()`, `MapCoreTests.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (3 nodes): `Dashboard.md`, `Obsidian Vault`, `Obsidian Vault Organization Design Spec`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 43`** (2 nodes): `DesignSystem`, `DesignSystem.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 45`** (2 nodes): `LocationRecording`, `LocationRecording.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 46`** (2 nodes): `PersistenceCore`, `PersistenceCore.swift`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 47`** (2 nodes): `ContentView`, `RideVerseApp`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 48`** (2 nodes): `DesignSystem SPM Package`, `DesignSystemGalleryApp`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 49`** (2 nodes): `HexGridIllustration`, `HexPathGenerator`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 50`** (2 nodes): `LocationPulseRing`, `RecPulseDot`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 51`** (2 nodes): `LocationKit Package`, `LocationRecording Module`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 52`** (2 nodes): `Design System Spec`, `Liquid Glass Design`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 53`** (2 nodes): `Screen: Recording`, `Screen: Trip Summary`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 54`** (2 nodes): `Fog-of-War Exploration Mechanic`, `Screen: Map`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 55`** (2 nodes): `FogRideModels`, `Trip (@Model)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 66`** (1 nodes): `FogPrimaryButtonStyle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 67`** (1 nodes): `FogLinkButtonStyle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 68`** (1 nodes): `StopButton`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 69`** (1 nodes): `FogSecondaryButtonStyle`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 70`** (1 nodes): `DesignSystemGallery`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 71`** (1 nodes): `UpsellCard`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 72`** (1 nodes): `FloatingGlassTabBar`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 73`** (1 nodes): `Color+FogRide Tokens`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 74`** (1 nodes): `FogSpacing`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 75`** (1 nodes): `FogRadius`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 76`** (1 nodes): `PulseAnimation`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 77`** (1 nodes): `OBIconContainer`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 78`** (1 nodes): `OnboardingDots`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 79`** (1 nodes): `MapVerse Package`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 80`** (1 nodes): `MapBBox`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 81`** (1 nodes): `HexCell+Hierarchy`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 82`** (1 nodes): `HexGeometry Module`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 83`** (1 nodes): `RideVerse (FogRide)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 84`** (1 nodes): `Screen: Stats`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 85`** (1 nodes): `Screen: Trip Detail`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 86`** (1 nodes): `Screen: Rides`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 87`** (1 nodes): `Screen: Onboarding`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 88`** (1 nodes): `Screen: Profile`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 89`** (1 nodes): `Screen: Paywall`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 90`** (1 nodes): `Screen: Live Activity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 91`** (1 nodes): `SwiftData+CloudKit Rules`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 92`** (1 nodes): `FogRide HTML Prototype`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 93`** (1 nodes): `Archive Architecture Doc`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 94`** (1 nodes): `Roadmap Index`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 95`** (1 nodes): `MapOfflineRegions`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 96`** (1 nodes): `LocationMotion`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 97`** (1 nodes): `Antipattern: God-Package FogRideKit`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 98`** (1 nodes): `Antipattern: DomainEvent with UI context`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 99`** (1 nodes): `Live Activity + Dynamic Island`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 100`** (1 nodes): `SCRUM-28 LocationRecording (prototype)`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 101`** (1 nodes): `SCRUM-29 PrototypeApp`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 102`** (1 nodes): `SCRUM-30 TestFlight + go/no-go`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `HexCell` connect `Liquid Glass System` to `DesignSystem Cards & Gallery`, `Fog Style & Error Types`, `HexBBox & Viewport Tests`?**
  _High betweenness centrality (0.120) - this node is a cross-community bridge._
- **Why does `HexCell` connect `HexKit Cell Hierarchy & Sets` to `Fog GeoJSON & Compaction`, `Hex Illustration UI`, `HexBBox & Viewport Tests`, `FogLayer & MapBBox`?**
  _High betweenness centrality (0.073) - this node is a cross-community bridge._
- **Why does `HexBBox` connect `HexBBox & Viewport Tests` to `Fog Style & Error Types`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Are the 53 inferred relationships involving `HexCell` (e.g. with `.allStatesRender()` and `makeCellSet()`) actually correct?**
  _`HexCell` has 53 INFERRED edges - model-reasoned connections that need verification._
- **Are the 36 inferred relationships involving `HexCellSet` (e.g. with `makeCellSet()` and `.emptyVisitedCellsProduceFullFog()`) actually correct?**
  _`HexCellSet` has 36 INFERRED edges - model-reasoned connections that need verification._
- **What connects `DesignSystem`, `ButtonStyle`, `ButtonStyle` to the rest of the system?**
  _149 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `DesignSystem Cards & Gallery` be split into smaller, more focused modules?**
  _Cohesion score 0.03 - nodes in this community are weakly interconnected._
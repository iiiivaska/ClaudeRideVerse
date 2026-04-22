# Phase 0 — Prototype
> 3-4 недели. Дешёвый прототип для валидации: "работает ли fog of war как retention-механика?"

## Цель

Собрать минимальное приложение: карта + туман войны + Start/Stop. Выложить в TestFlight, снять видео, опубликовать, собрать обратную связь. Цель — проверить гипотезу, что fog of war на реальных поездках цепляет пользователей, прежде чем вкладывать 150+ часов в MVP.

Реализуются базовые пакеты: [[HexCore]], [[HexGeometry]], [[MapCore]], [[MapFogOfWar]], [[LocationRecording]].

## Go/No-Go критерии

- **500+ upvotes** на видео (TikTok / Reddit / Twitter)
- **20-30 pre-orders** или подписок на waitlist
- Субъективная оценка: туман войны действительно вызывает желание "открыть ещё"

## Задачи (Jira)

- **SCRUM-21** [0.1] [[HexCore]] — SwiftyH3 wrapper (3-4ч) — **DONE** (PR #3, коммит `97abb85`)
  - SCRUM-22 Add SwiftyH3 0.5.0 SPM dependency — **DONE**
  - SCRUM-23 Create HexCell + HexResolution types — **DONE**
  - SCRUM-24 HexCell API + unit tests — **DONE**
  - 6 source files, 35 тестов в 6 suites (Swift Testing), pentagon edge cases покрыты
  - Типы: `HexCell` (Hashable, Sendable), `HexResolution` (r0-r15), `HexMultiPolygon`, `HexError`, `HexCellBatch`
  - API: center/boundary/isPentagon, neighbors/parent/children/gridDistance, cellsToMultiPolygon
- **SCRUM-25** [0.2] [[HexGeometry]] — compaction, multipolygon, viewport culling (3-4ч) — **DONE** (PR #4, коммит `4751ad0`)
  - HexCellSet struct: Set-обёртка с insert/merge/contains/compacted/multiPolygon/viewport culling
  - HexBBox: локальный bounding box (MapBBox отложен до MapCore)
  - Compaction через SwiftyH3 `compactCells` — 7 r9 → 1 r8
  - MultiPolygon делегирует в HexCellBatch.boundary(of:)
  - Viewport culling: O(n) center check с 50% buffer expansion
  - 36 тестов в 5 suites (compaction, multipolygon, viewport, bbox, pentagon edge cases)
- **SCRUM-26** [0.3] [[MapCore]] — MapLibre SwiftUI wrapper + Stadia Outdoors (3-4ч) — **DONE** (PR #5, ветка `SCRUM-26`)
  - MapLibre Native 6.25.1 + MapLibre SwiftUI DSL 0.21.1 SPM зависимости
  - `MapCamera` (Sendable, Equatable) с binding + анимации, пресет `.amsterdam`
  - `MapBBox` (Sendable, Equatable) с `contains`, `expanded`, MLN bridging
  - `MapStyle` — Stadia Outdoors URL + `STADIA_API_KEY` из environment + `.demotiles` fallback
  - `MapContent` протокол + `@MapContentBuilder` result builder (EmptyMapContent, MapContentGroup, OptionalMapContent, ConditionalMapContent)
  - `MapView<Content: MapContent>` — SwiftUI view с `UIViewRepresentable` + Coordinator
  - `MapViewRepresentable` — MLNMapView обёртка с двусторонним camera binding (guard от feedback loop)
  - HexBBox остаётся в HexGeometry (независимость пакетов); bridging в SCRUM-27
  - 26 тестов в 5 suites (MapCamera, MapBBox, MapStyle, MapContentBuilder, module smoke)
- **SCRUM-27** [0.4] [[MapFogOfWar]] — inverted MultiPolygon (4-5ч) — **DONE** (ветка `SCRUM-27`)
  - `VisitedCells` protocol: H3-aware contract returning `HexCellSet` for viewport + zoom
  - `FogGeoJSONBuilder`: inverted MultiPolygon GeoJSON (world frame exterior + hex outer rings as holes + re-fog patches for inner holes)
  - `FogResolutionPolicy`: zoom > 14 → r9, 10-14 → r7, < 10 → r5
  - `FogLayer: MapContent` с `geoJSON(in:atZoom:)` для MapLibre `MLNShapeSource`
  - `FogStyle`: fogColor, opacity, edgeColor, pulseNewCells
  - `FogUpdateThrottle`: actor-based rate limiter (default 1/sec)
  - 23 теста в 5 suites (FogResolutionPolicy, FogStyle, FogGeoJSONBuilder, FogLayer, FogUpdateThrottle)
- **SCRUM-28** [0.5] [[LocationRecording]] — minimal foreground version (2-3ч) — **DONE** (ветка `SCRUM-28`)
  - `LocationRecorder` actor: start/pause/resume/stop lifecycle, idempotent start()
  - `RawLocation` Sendable struct (not CLLocation — CLLocation not Sendable)
  - `RecordingConfiguration` with .cycling/.walking presets
  - `RecordingState` enum + `LocationRecordingError` typed error (Sendable+Equatable)
  - Internal `LocationSource` protocol + `CLLocationUpdateSource` (wraps CLLocationUpdate.liveUpdates(.fitness))
  - Foreground-only for Phase 0 (background session deferred to Phase 1)
  - 24 теста в 4 suites (RawLocation, RecordingConfiguration, RecordingState, LocationRecorder)
- **SCRUM-29** [0.6] PrototypeApp — map + fog + Start/Stop screen (3-4ч код + 2-3ч полевые тесты) — **DONE** (мерж в `main`, коммит `f844383`)
  - `PrototypeView` + `PrototypeMapView` (UIViewRepresentable вокруг `MLNMapView`) + `PrototypeViewModel` + `HexGridBuilder` живут в app-таргете `RideVerse/RideVerse/Prototype/` (одноразовый код, не в SPM)
  - Карта: OpenFreeMap (без API key) с fallback на Stadia Outdoors через `STADIA_API_KEY` env
  - Hex grid рендерится как `MLNFillStyleLayer` + `MLNLineStyleLayer` поверх `MLNShapeSource`, два state'а (`s=0` unexplored / `s=1` explored) через data-driven color
  - `coverViewport` через H3 `gridDisk` от центра viewport (НЕ lat/lon walk) — гарантирует покрытие центра экрана при любых зумах
  - `adjustedResolution`: автоматически переключается на более грубое разрешение, если оценка ячеек > `maxCells (5000)` — на zoom 2-3 уходит в r1/r2
  - `boundaryCache`: shared `[UInt64: [CLLocationCoordinate2D]]` под `NSLock` (Phase 1: lookup + collect misses, Phase 2: H3 boundary вне lock'а, Phase 3: write back) — без блокировки `Task.detached`-перебилды гонялись и крэшили `Dictionary`
  - `mapViewRegionIsChanging` с throttle 30 Hz — fog «едет» вместе с картой во время жеста
  - `lastSyncedCamera` в `Coordinator` предотвращает echo `applyCamera` после нашего же push'а в `@Binding` (иначе `setCamera(animated:)` дрался с пользовательским жестом и снапил камеру обратно)
  - Visited cells сохраняются на storage resolution `r10` через `HexCellSet`; `displayResolution` маппится из текущего zoom через `FogResolutionPolicy`, parents/children считаются на лету
  - `FogResolutionPolicy` расширен с 3 до 8 zoom-tiers (r3..r10) для адаптивной детализации на всех зумах
  - Live updates во время жеста: 50 ms debounce в `handleVisibleBoundsChange`, 15% buffer вокруг viewport
- **SCRUM-30** [0.7] ~~TestFlight + публикация + feedback + go/no-go~~ — **ПЕРЕНЕСЁН в EPIC-1** как [1.16]
  - Решение: показывать комьюнити MVP, а не прототип
  - Prep-работа сделана: prototype polish (onboarding, HUD, track polyline, ride summary, app icon), TestFlight настроен (TraVerse, сборка 1.1 загружена), privacy policy опубликована
  - Распространение и сбор фидбэка будут после завершения Phase 1 MVP

## Итог Phase 0

✅ **Phase 0 завершена.** Все пакеты реализованы (HexCore, HexGeometry, MapCore, MapFogOfWar, LocationRecording), прототип собран и отполирован, TestFlight инфраструктура настроена. Приложение переименовано в **TraVerse** (com.iiiivaska.TraVerse). Переходим к Phase 1 — MVP.

## Ключевые решения

- Прототип — одноразовый: код может быть грязным, главное — быстро проверить гипотезу
- LocationRecording только foreground — фоновая запись будет в Phase 1
- MapLibre выбран вместо Apple Maps ради офлайн-карт (PMTiles) и гибкости стилей
- SwiftyH3 0.5.0 — обёртка над C-библиотеку H3 от Uber, Resolution 9 (~174м) как основной уровень

## Зависимости

- Требует: [[Phase F — Foundation]]
- Блокирует: [[Phase 1 — MVP]]

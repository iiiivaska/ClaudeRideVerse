# MapVerse -- группа пакетов для карт
> Четыре пакета: MapCore, MapOverlays, MapFogOfWar, MapOfflineRegions. Декларативная SwiftUI-обёртка над MapLibre, оверлеи, fog of war рендеринг и оффлайн-карты.

### Почему 4 пакета, а не один

Соблазн -- один `FogRideMap` со всем внутри. Но это ошибка:
1. `MapOfflineRegions` имеет специфические зависимости и тестируется только на устройстве -- не хочется тащить в unit-тесты `MapFogOfWar`.
2. `MapFogOfWar` использует H3 (через [[HexKit]]), а `MapOverlays` -- нет. Приложение, которое хочет просто показать polyline, не должно тянуть H3.
3. Каждый пакет может эволюционировать независимо.

---

## MapCore

**Назначение:** декларативная SwiftUI-обёртка над MapLibre Native с контролем камеры, стилей и жизненного цикла карты.

**Статус:** реализован (SCRUM-26). MapLibre Native 6.25.1, MapLibre SwiftUI DSL 0.21.1.

### Реализованный API (SCRUM-26)

```swift
// Камера — value-type, Sendable, Equatable
public struct MapCamera: Sendable, Equatable {
    public let center: CLLocationCoordinate2D
    public let zoom: Double
    public let bearing: Double
    public let pitch: Double
    public static let amsterdam: MapCamera // preset
}

// Bounding box с MLNCoordinateBounds bridging
public struct MapBBox: Sendable, Equatable {
    public let northEast: CLLocationCoordinate2D
    public let southWest: CLLocationCoordinate2D
    public func contains(_ coordinate: CLLocationCoordinate2D) -> Bool
    public func expanded(by factor: Double) -> MapBBox
    public var centerCoordinate: CLLocationCoordinate2D  // SCRUM-29 — для gridDisk-from-center
}

// Стиль — URL с Stadia Outdoors и демо-тайлами
public struct MapStyle: Sendable, Equatable {
    public let url: URL
    public static func stadiaOutdoors(apiKey: String) -> MapStyle
    public static func stadiaOutdoorsFromEnvironment() -> MapStyle?
    public static let demotiles: MapStyle
}

// Контент — протокол и result builder
public protocol MapContent: Sendable {}
@resultBuilder public enum MapContentBuilder { ... }

// Карта — SwiftUI view с UIViewRepresentable (iOS only)
public struct MapView<Content: MapContent>: View {
    public init(camera: Binding<MapCamera>, style: MapStyle,
                @MapContentBuilder content: () -> Content)
}
```

### Планируемый API (будущие задачи)

```swift
// MapController — escape-hatch к MLNMapView (будет в follow-up)
public final class MapController {
    public func setCamera(_ camera: MapCamera, animated: Bool)
    public func fit(coordinates: [CLLocationCoordinate2D], padding: EdgeInsets)
    public func snapshot(size: CGSize) async throws -> UIImage
    public var underlyingMapView: MLNMapView { get }
}

// Callbacks — onMapLoad, onRegionChange (будет при необходимости)
```

### Ключевые обязанности

- Обёртка MapLibre через `UIViewRepresentable` + `Coordinator` с `MLNMapViewDelegate`.
- `MapCamera` как `Equatable` value-type с двусторонним binding (guard `isUpdatingFromBinding`/`isUpdatingFromDelegate` предотвращает feedback loop).
- `MapStyle` — фабричные методы для Stadia Outdoors (API key из environment) и MapLibre demo tiles (без ключа, для CI/previews).
- `MapContentBuilder` — result builder для декларативной композиции оверлеев (EmptyMapContent, MapContentGroup, OptionalMapContent, ConditionalMapContent).
- `MapBBox` — bounding box с MLNCoordinateBounds bridging. HexBBox живёт отдельно в HexGeometry (независимость пакетов); bridging будет в MapFogOfWar.
- `#if canImport(UIKit)` — view-код iOS-only, value-types кроссплатформенные.

### Что намеренно НЕ входит

- Провайдеры стилей (Stadia, MapTiler) -- работа уровня приложения.
- Полилинии, маркеры -- отдельный пакет MapOverlays.
- Любая логика FogRide.
- `MapController` — отложен до реальной необходимости (SCRUM-27+).
- `onRegionChange` throttling — будет добавлен при реализации fog viewport culling.

### Тесты

- 26 тестов в 5 suites (Swift Testing):
  - `MapCameraTests` (8) — init, equality, inequality, amsterdam preset, Sendable
  - `MapBBoxTests` (6) — contains, boundary, expanded, equality
  - `MapStyleTests` (5) — Stadia URL, demo tiles, equality
  - `MapContentBuilderTests` (5) — empty, single, pair, triple, optional
  - `MapCoreModuleTests` (1) — module import smoke
  - `MapFogOfWarTests` (1) — downstream compatibility
- Preview: `MapView+Preview.swift` с Amsterdam demo tiles и Stadia Outdoors

---

## MapOverlays

**Назначение:** декларативные оверлеи поверх MapCore -- полилинии, маркеры, circles, hit-testing.

### Публичный API

```swift
public struct TrackPolyline: MapContent {
    public init(
        id: String,
        coordinates: [CLLocationCoordinate2D],
        style: PolylineStyle = .default
    )
}

public struct Marker<Label: View>: MapContent {
    public init(
        id: String,
        coordinate: CLLocationCoordinate2D,
        anchor: MarkerAnchor = .center,
        @ViewBuilder label: () -> Label
    )
}

public struct PolylineStyle {
    public var color: Color
    public var width: CGFloat
    public var pattern: [CGFloat]?
    public var gradient: [(stop: Double, color: Color)]?  // для высотных профилей
}

public struct ClusterLayer<Item: Identifiable>: MapContent where Item: Hashable { ... }
```

### Ключевые обязанности

- Эффективная отрисовка трека из 10k+ точек -- ОДИН `MLNLineStyleLayer`, не перестройка при каждом update.
- Градиентные полилинии (пульс, высота, скорость раскрашивают трек).
- Marker clustering через MapLibre native cluster-source.
- Hit-testing: тап по polyline возвращает ближайший coordinate + индекс.
- `@MapContentBuilder` композиция: `FogMap { TrackPolyline(...); Marker(...) }`.

### Что НЕ входит

- Fog of war (отдельный пакет -- другая логика рендера).
- Heatmap на уровне агрегированных данных (возможно, появится позже как `MapHeatmap` пакет).

### Зависимости

- MapCore

---

## MapFogOfWar

**Назначение:** рендерер fog of war через inverted multipolygon -- принимает visited hex cells, выдаёт GeoJSON для MapLibre `MLNShapeSource`.

**Статус:** реализован (SCRUM-27). Зависит от MapCore (MapBBox, MapContent) и HexKit (HexCellSet, HexMultiPolygon).

### Реализованный API (SCRUM-27)

```swift
// Контракт для источника visited-ячеек
public protocol VisitedCells: Sendable {
    func cellSet(in bbox: MapBBox, atZoom zoom: Double) -> HexCellSet
}

// MapContent для декларативной композиции в MapView
public struct FogLayer: MapContent {
    public init(visited: any VisitedCells, style: FogStyle = .default)
    public func geoJSON(in bbox: MapBBox, atZoom zoom: Double) -> Data
}

// Стилизация тумана
public struct FogStyle: Sendable, Equatable {
    public var fogColor: Color      // default: .black
    public var opacity: Double      // default: 0.7
    public var edgeColor: Color?    // default: nil
    public var pulseNewCells: Bool  // default: true
    public static let `default`: FogStyle
}

// Zoom → H3 resolution mapping (расширено в SCRUM-29 до 8 tiers)
public enum FogResolutionPolicy: Sendable {
    public static func resolution(forZoom zoom: Double) -> HexResolution
    // ≥ 14 → r10  | 12-13 → r9 | 10-11 → r8 | 8-9 → r7
    // 6-7  → r6  | 4-5  → r5  | 2-3   → r4 | < 2  → r3
}

// Построитель инвертированного MultiPolygon GeoJSON
public enum FogGeoJSONBuilder: Sendable {
    public static func buildGeoJSON(from multiPolygon: HexMultiPolygon) -> Data
    public static func buildEmptyFogGeoJSON() -> Data
}

// Rate limiter для обновлений GeoJSON source (default: 1/sec)
public actor FogUpdateThrottle {
    public init(interval: Duration = .seconds(1))
    public func shouldUpdate() -> Bool
    public func reset()
}
```

### Ключевые обязанности

- Inverted MultiPolygon: мировой прямоугольник (exterior ring, Web Mercator ±85°) с visited hex boundaries как holes.
- Re-fog patches: внутренние дыры в visited-полигонах (острова непосещённых ячеек) становятся отдельными полигонами в MultiPolygon.
- GeoJSON output: `[longitude, latitude]` координатный порядок, RFC 7946 CCW exterior ring.
- `FogUpdateThrottle`: actor-based throttle до 1 Hz для MapLibre source updates.
- Zoom-aware resolution: `FogResolutionPolicy` для адаптивной детализации по zoom.

### Что пакет НЕ знает

- Про хранилище visited-ячеек. Адаптер в app layer загружает их откуда угодно: из памяти, из GRDB, из CloudKit.
- Про MLNMapView. Пакет генерирует GeoJSON Data; привязка к MapLibre source/layer — ответственность MapView integration (SCRUM-29).

### Тесты

- 23 теста в 5 suites (Swift Testing):
  - `FogResolutionPolicyTests` (5) — zoom boundaries, r9/r7/r5 mapping
  - `FogStyleTests` (4) — defaults, custom, equality/inequality
  - `FogGeoJSONBuilderTests` (6) — empty fog, single hole, multiple holes, re-fog patches, coordinate order
  - `FogLayerTests` (4) — empty cells, visited cells, MapContent conformance, custom style
  - `FogUpdateThrottleTests` (3) — first call, blocked call, reset

### Зависимости

- MapCore, [[HexKit|HexGeometry]] (через протокол `VisitedCells`)

Используется в: [[Domain|FogMapFeature]]

---

## MapOfflineRegions

**Назначение:** управление оффлайн-картами через PMTiles (приоритет) и `MLNShapeOfflineRegion` (fallback для vector-стилей).

### Публичный API

```swift
public actor OfflineRegionsManager {
    public func downloadPMTiles(
        url: URL,
        destination: URL,
        progress: AsyncStream<Double>.Continuation
    ) async throws
    
    public func downloadShapeRegion(
        bounds: MapBBox,
        styleURL: URL,
        minZoom: Double,
        maxZoom: Double
    ) async throws -> OfflineRegionID
    
    public func listRegions() async -> [OfflineRegion]
    public func delete(_ id: OfflineRegionID) async throws
    public func totalSize() async -> Int64
}
```

### Важный gotcha

`MLNOfflinePack` с PMTiles сломан (issues #3690, #3691). Пакет инкапсулирует эту боль: для PMTiles -- прямое скачивание файла через `URLSession.download` + регистрация `pmtiles://file://...` URL в MapLibre. Для vector-стилей через Stadia -- честный `MLNShapeOfflineRegion`.

### Зависимости

- MapLibre

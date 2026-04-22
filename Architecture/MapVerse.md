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

**Назначение:** hex-agnostic рендерер fog of war через inverted multipolygon -- принимает абстрактные «visited cells», выдаёт GeoJSON слой.

Критично: пакет **не знает про H3**. Протокол `VisitedCells` принимает любую реализацию -- H3, S2, axial hex, квадраты. В FogRide используется `HexCellSetFogAdapter` из [[HexKit|HexGeometry]], но сам MapFogOfWar от этого не зависит.

### Публичный API

```swift
public struct FogOfWarLayer: MapContent {
    public init(
        visited: VisitedCells,
        style: FogStyle = .default,
        newCellAnimation: NewCellAnimation? = .pulse
    )
}

public protocol VisitedCells {
    /// Вернуть границы «дыр» в тумане для данного viewport и уровня детализации.
    func holes(in bbox: MapBBox, detail: FogDetailLevel) -> [[CLLocationCoordinate2D]]
    /// Контрольная сумма для инвалидации кэша; меняется при добавлении новой ячейки.
    var revision: Int { get }
}

public enum FogDetailLevel {
    case auto(zoom: Double)
    case fixed(resolution: Int)
}

public struct FogStyle {
    public var color: Color = .black
    public var opacity: Double = 0.7
    public var borderColor: Color? = nil
    public var borderWidth: CGFloat = 0
    public var edgeSoftening: Double = 0  // 0 = hard, 1 = soft
}

public enum NewCellAnimation {
    case none
    case pulse(duration: TimeInterval)
    case fadeIn(duration: TimeInterval)
}
```

### Ключевые обязанности

- Один большой `MLNFillStyleLayer` с inverted MultiPolygon.
- Throttle обновлений GeoJSON source до 1-2 Hz даже если `revision` меняется чаще.
- Viewport culling: запрашивать у `VisitedCells.holes` только для видимой области + буфер 50%.
- Адаптивная детализация по zoom: при далёком zoom -- `detail: .auto` вернёт грубые полигоны.
- Анимация появления новой ячейки: pulse через expression-based `fill-opacity`.

### Что пакет НЕ знает

- Про H3. Протокол `VisitedCells` абстрактен.
- Про хранилище visited-ячеек. Адаптер загружает их откуда угодно: из памяти, из GRDB, из CloudKit.

### Тесты

- Unit: корректность inverted MultiPolygon для fixture-наборов точек (включая edge case пересечения антимеридиана).
- Snapshot: рендер 100 / 1000 / 10000 hex.
- Performance: FPS benchmark на 10k ячеек (target >= 55 FPS на iPhone 14).

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

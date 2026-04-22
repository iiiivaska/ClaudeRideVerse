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

### Публичный API

```swift
public struct FogMap<Content: MapContent>: View {
    public init(
        camera: Binding<MapCamera>,
        styleURL: URL,
        @MapContentBuilder content: () -> Content
    )
    public func onMapLoad(_ action: @escaping (MapController) -> Void) -> Self
    public func onRegionChange(_ action: @escaping (MapRegion) -> Void) -> Self
}

public struct MapCamera {
    public var center: CLLocationCoordinate2D
    public var zoom: Double
    public var pitch: Double
    public var bearing: Double
}

public protocol MapContent { /* result builder protocol */ }

public final class MapController {
    public func setCamera(_ camera: MapCamera, animated: Bool)
    public func fit(coordinates: [CLLocationCoordinate2D], padding: EdgeInsets)
    public func snapshot(size: CGSize) async throws -> UIImage
    public var underlyingMapView: MLNMapView { get } // escape hatch
}
```

### Ключевые обязанности

- Обёртка MapLibre через `UIViewRepresentable`, стабильная к перезапускам и smooth при частых `setState`.
- `MapCamera` как `Equatable` value-type с anim-aware биндингом (если изменилось только `zoom` -- анимируем только zoom).
- Escape-hatch `underlyingMapView` -- честное признание, что DSL не покроет 100% кейсов.
- Throttling `onRegionChange` (не чаще 30 Hz) -- предотвращает шторм обновлений при панораме.
- Контроль жизненного цикла: `applicationWillResignActive` -- приостановить рендер; `didBecomeActive` -- возобновить. Важно для батареи.

### Что намеренно НЕ входит

- Провайдеры стилей (Stadia, MapTiler) -- работа уровня приложения.
- Полилинии, маркеры -- отдельный пакет MapOverlays.
- Любая логика FogRide.

### Тесты

- Unit: `MapCamera` equatable/diff, `MapContentBuilder` композиция.
- Snapshot: SwiftUI preview карты с fixture-стилем на тестовом JSON.
- Integration (на устройстве): загрузка стиля, fit coordinates, snapshot rendering.

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

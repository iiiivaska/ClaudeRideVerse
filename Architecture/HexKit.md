# HexKit -- группа пакетов для H3-сетки
> Два пакета: HexCore и HexGeometry. Типобезопасная обёртка над H3, compaction-алгоритмы, двухуровневое хранение, адаптер для fog of war.

### Почему два пакета, а не один

1. **HexCore -- тонкая обёртка над C-библиотекой H3 через SwiftyH3.** Максимально стабильна, минимум логики. Переносима в любой проект с H3 без специфического кода multipolygon-слияния.
2. **HexGeometry -- алгоритмы поверх H3.** Compaction, MultiPolygon-операции, итераторы по сетке. Здесь допустимы тяжёлые зависимости (GEOS, если понадобится), оптимизации, кеши.
3. **Разные ритмы изменений.** HexCore меняется только при апгрейде H3 (раз в год). HexGeometry дописывается постоянно, пока дорабатывается fog-механика.

---

## HexCore

**Назначение:** строго-типизированная Swift-обёртка над H3, которая делает H3-индексы first-class Swift-объектами и защищает от путаницы resolutions.

### Зачем обёртка над SwiftyH3

SwiftyH3 -- хорошая библиотека, но её API -- прямой маппинг C-функций: `latLngToCell(lat, lng, resolution) -> UInt64`. Это рабочий, но небезопасный API: `UInt64` не несёт информации о resolution, легко перепутать индексы разных уровней, нет защиты от невалидных значений. HexCore добавляет слой типов, который делает эти ошибки невозможными на этапе компиляции.

Плюс -- SwiftyH3 может стать abandonware. Если код написан против обёртки, миграция на другую H3-библиотеку сводится к одному файлу.

### Публичный API

```swift
public enum HexResolution: Int, Sendable, CaseIterable, Comparable {
    case r0 = 0   // ~1107 km edge
    // ...
    case r8 = 8   // ~461 m edge
    case r9 = 9   // ~174 m edge -- дефолт FogRide
    // ...
    case r15 = 15  // ~0.5 m edge
    
    public var averageEdgeMeters: Double { ... }
    public var averageAreaSquareMeters: Double { ... }
    public var averageDiameterMeters: Double { ... }
}

public struct HexCell: Hashable, Sendable, CustomStringConvertible {
    public let index: UInt64
    public let resolution: HexResolution
    
    public init(coordinate: CLLocationCoordinate2D, resolution: HexResolution)
    public init?(index: UInt64, strict: Bool = false)
    
    public var center: CLLocationCoordinate2D { get }
    public var boundary: [CLLocationCoordinate2D] { get }  // 6 вершин, 5 для pentagon
    public var isPentagon: Bool { get }
}

extension HexCell {
    public func neighbors(within k: Int) -> Set<HexCell>
    public var immediateNeighbors: Set<HexCell> { get }
    public func parent(at resolution: HexResolution) -> HexCell?
    public func children(at resolution: HexResolution) -> Set<HexCell>
    public func gridDistance(to other: HexCell) -> Int?
}

public enum HexCellBatch {
    public static func cells(
        for coordinates: [CLLocationCoordinate2D],
        resolution: HexResolution
    ) -> Set<HexCell>
    
    public static func boundary(of cells: Set<HexCell>) -> HexMultiPolygon
}

public struct HexMultiPolygon: Sendable {
    public struct Polygon: Sendable {
        public let outer: [CLLocationCoordinate2D]
        public let holes: [[CLLocationCoordinate2D]]
    }
    public let polygons: [Polygon]
}

public enum HexError: Error {
    case invalidCoordinate
    case resolutionMismatch(expected: HexResolution, got: HexResolution)
    case antimeridianCrossing
    case pentagonEncountered
}
```

### Ключевые обязанности

- **Типобезопасность resolution.** Методы принимают `HexResolution`, а не `Int`.
- **Инкапсуляция pentagons.** В каждом resolution есть 12 пентагонов -- ячеек с 5 соседями. `HexCell.isPentagon` явно маркирует; `gridDistance` возвращает `nil`, если путь затронул pentagon.
- **Известный баг антимеридиана** в `cellsToMultiPolygon` -- пакет ловит его, возвращая `HexError.antimeridianCrossing`.
- **Sendable everywhere.** Все структуры -- `Sendable` для Swift 6 concurrency mode.

### Что пакет НЕ делает

- Не рендерит (никаких MapLibre-зависимостей, никакого SwiftUI).
- Не знает про fog of war (просто операции над H3).
- Не хранит (никакой GRDB, никакого CoreData -- это [[Прочие пакеты|PersistenceCore]]).
- Не компактует (это HexGeometry).

### Реализация (SCRUM-21, коммит `97abb85`)

**Файлы:** `Packages/HexKit/Sources/HexCore/`
- `HexResolution.swift` — enum r0-r15 с hardcoded H3 resolution tables (edge/area)
- `HexCell.swift` — struct(UInt64, HexResolution), init from coord/index, center/boundary/isPentagon
- `HexCell+Hierarchy.swift` — neighbors(within:), parent(at:), children(at:), gridDistance(to:)
- `HexCellBatch.swift` — cells(for:resolution:), boundary(of:) via `Sequence<H3Cell>.multiPolygon`
- `HexMultiPolygon.swift` — Polygon(outer, holes), `@unchecked Sendable`
- `HexError.swift` — invalidCoordinate, resolutionMismatch, antimeridianCrossing, pentagonEncountered

**Решения:**
- `HexCell` хранит только `UInt64` + `HexResolution` → автоматически Sendable, координаты computed
- `@preconcurrency import SwiftyH3` для подавления Sendable warnings из C-библиотеки
- `HexMultiPolygon.Polygon` — `@unchecked Sendable` (CLLocationCoordinate2D не формально Sendable)
- Internal `init(trusted:resolution:)` для обёрток SwiftyH3 outputs без повторной валидации
- Metric properties (averageEdgeMeters, averageAreaSquareMeters) — hardcoded lookup, не runtime H3 calls

### Тесты

35 тестов в 6 suites (Swift Testing):
- **HexResolution** (6): 16 cases, comparable, edge/area spot-check, monotonic decrease
- **HexCell Init** (6): from coord, valid/invalid index, description, equality, resolution independence
- **HexCell Properties** (3): center proximity, boundary vertex count (6 hex), isPentagon=false for SF
- **HexCell Pentagon** (4): 12 r0 pentagons found, isPentagon=true, 5 neighbors, 5 boundary vertices
- **HexCell Hierarchy** (12): neighbors count/exclusion, parent/children/roundtrip, gridDistance 0/1/nil
- **HexCellBatch** (4): deduplication, multiple coords, cluster boundary, empty set

### Зависимости

- SwiftyH3 0.5.0 (Apache 2.0)

---

## HexGeometry

**Назначение:** алгоритмы над наборами ячеек -- compaction по zoom, эффективные multipolygon-операции, итераторы по сетке, адаптеры для [[MapKit|MapFogOfWar]].

### Реализация (SCRUM-25, коммит `4751ad0`)

**Файлы:** `Packages/HexKit/Sources/HexGeometry/`
- `HexBBox.swift` — struct(south/west/north/east: Double), expanded(by:), contains(_:)
- `HexCellSet.swift` — struct wrapping Set<HexCell>, init/insert/count/contains/merged
- `HexCellSet+Compaction.swift` — compacted() через SwiftyH3 `Sequence<H3Cell>.compacted`
- `HexCellSet+MultiPolygon.swift` — multiPolygon() делегирует в HexCellBatch.boundary(of:), outerBoundaries convenience
- `HexCellSet+ViewportCulling.swift` — cells(in: HexBBox) с O(n) center check + 50% buffer

**Решения:**
- `HexCellSet` — struct (value type), не class/actor. Эволюция в actor при hot/cold storage — позже
- `HexBBox` — локальный тип вместо MapBBox (MapCore ещё не реализован)
- Compaction: `try?` — при ошибке (mixed resolutions) возвращает self
- MultiPolygon: делегирует в HexCore `HexCellBatch.boundary(of:)`, не дублирует SwiftyH3 calls
- Viewport culling: brute-force O(n), R-tree отложен
- SwiftyH3 добавлен как зависимость HexGeometry target (для compaction API)

**Тесты:** 36 тестов в 5 suites (Swift Testing):
- **HexBBox** (5): contains inside/outside/edge, expanded math, init from corners
- **HexCellSet** (11): init/insert/contains/merged/equatable
- **HexCellSet Compaction** (7): 7 r9→1 r8, partial no-compact, idempotent, pentagon, mixed-resolution
- **HexCellSet MultiPolygon** (6): single cell, cluster, 100-hex, disjoint 2 polygons, empty, outerBoundaries
- **HexCellSet Viewport Culling** (6): inside/outside/buffer, empty, whole-world, partial return

**Отложено (future tasks):**
- HexCompaction enum (lossyCompact, uncompact)
- HexGridIterator (polygon/line fill)
- IncrementalMultiPolygonBuilder (actor)
- HexCellSetFogAdapter (VisitedCells protocol bridge)
- CompactedHexSnapshot (Codable persistence)
- Two-layer hot/cold storage, R-tree bbox index

### Ключевые сценарии

1. **Хранение и загрузка миллионов visited-ячеек.** Нельзя хранить 100k raw ячеек r9 в памяти -- через compaction это ~10k на разных resolutions.
2. **Запрос visited для viewport.** Карта тянет: «дай мне все visited в этом bbox для zoom 12». Нужно быстро.
3. **Инкрементальное добавление ячейки.** Каждая GPS-точка -- возможно, новая ячейка. Обновление без полного пересчёта.
4. **Fog-of-war адаптер.** Реализация протокола `VisitedCells` из [[MapKit|MapFogOfWar]].

### Публичный API

```swift
public final class HexCellSet: Sendable {
    public init()
    public init(compactedSnapshot: CompactedHexSnapshot)
    
    @discardableResult
    public func insert(_ cell: HexCell) async -> InsertResult
    public func insert(contentsOf cells: some Sequence<HexCell>) async
    
    public func contains(_ cell: HexCell) async -> Bool
    public var count: Int { get async }
    
    public func cells(
        in bbox: MapBBox, detail: HexResolution
    ) async -> Set<HexCell>
    
    public func holes(
        in bbox: MapBBox, detail: HexResolution
    ) async -> [[CLLocationCoordinate2D]]
    
    public var revision: Int { get async }
    public func compactedSnapshot() async -> CompactedHexSnapshot
    
    public enum InsertResult: Sendable {
        case inserted       // ячейка была новой
        case alreadyPresent // уже была
        case upgraded       // произошла компактизация родителя
    }
}

public struct CompactedHexSnapshot: Codable, Sendable {
    public let compactedCells: [HexCell]
    public let version: Int
}

public enum HexCompaction {
    public static func compact(_ cells: Set<HexCell>) -> Set<HexCell>
    public static func uncompact(_ cells: Set<HexCell>, to resolution: HexResolution) -> Set<HexCell>
    public static func lossyCompact(
        _ cells: Set<HexCell>,
        toResolution targetResolution: HexResolution,
        threshold: Double
    ) -> Set<HexCell>
}

public enum HexGridIterator {
    public static func cells(
        in polygon: [CLLocationCoordinate2D], resolution: HexResolution
    ) -> AsyncStream<HexCell>
    
    public static func cells(
        along line: [CLLocationCoordinate2D], resolution: HexResolution
    ) -> [HexCell]
}
```

### Двухуровневая модель хранения в HexCellSet

- **Hot layer**: `Set<HexCell>` на native resolution (r9) для последних N изменений. O(1) вставка, быстрый contains.
- **Cold layer**: compacted-дерево родительских ячеек. Обновляется батчами или по таймеру (раз в ~30 секунд или при достижении threshold в hot layer).
- **Bbox index**: R-tree или простой grid index поверх `(bbox -> cells)` для быстрых viewport-запросов.

Когда в hot layer попадают все 7 детей какого-то r8-родителя, они схлопываются в одну r8-ячейку в cold layer.

### Adaptive compaction для рендеринга

Карта на zoom 10, viewport 50 км. Если рисовать всё в r9 -- тысячи полигонов. Стратегия:

| Zoom | Detail | Метод |
|---|---|---|
| z >= 13 | r9 (native) | Прямые ячейки |
| z 11-12 | r8 | `lossyCompact` с threshold 0.5 |
| z 9-10 | r7 | `lossyCompact` |
| z <= 8 | r6 | Грубые полигоны |

`lossyCompact` -- не идеален математически (hex не делится ровно по resolution-границам), но визуально незаметно при zoom out.

### Multipolygon -- эффективная реализация

`HexCellBatch.boundary` из HexCore использует H3 native `cellsToMultiPolygon`. Для больших наборов медленно. В HexGeometry добавлен:

```swift
public actor IncrementalMultiPolygonBuilder {
    public init()
    public func add(_ cell: HexCell) async
    public func remove(_ cell: HexCell) async
    public func currentBoundary() async -> HexMultiPolygon
}
```

Для MVP -- полный пересчёт раз в секунду на 10k ячеек укладывается в 50ms.

### HexCellSetFogAdapter

Мост между `HexCellSet` и протоколом `VisitedCells` из [[MapKit|MapFogOfWar]]. Единственная работа -- конвертировать `FogDetailLevel.auto(zoom:)` в `HexResolution` и делегировать запрос в `HexCellSet`.

Архитектурно важен: живёт в HexGeometry, который знает и про `HexCell`, и про `MapFogOfWar`. Таким образом **MapFogOfWar не зависит от H3 напрямую, а HexGeometry не зависит от MapLibre** -- зависимость идёт через общий контракт `VisitedCells`.

```swift
public struct HexCellSetFogAdapter: VisitedCells {
    public init(cellSet: HexCellSet)
    public func holes(in bbox: MapBBox, detail: FogDetailLevel) -> [[CLLocationCoordinate2D]]
    public var revision: Int { ... }
}
```

### Persistence-схема для GRDB

HexGeometry не тянет GRDB в зависимости, но определяет `CompactedHexSnapshot: Codable`. Конкретная таблица GRDB живёт в [[Domain|FogRidePersistence]]:

```sql
CREATE TABLE user_hex_snapshots (
    id INTEGER PRIMARY KEY,
    snapshot_blob BLOB NOT NULL,  -- encoded CompactedHexSnapshot
    updated_at INTEGER NOT NULL,
    revision INTEGER NOT NULL
);

-- Альтернативно, плоская таблица для инкрементального обновления:
CREATE TABLE user_hex_cells (
    h3_index INTEGER NOT NULL,
    h3_resolution INTEGER NOT NULL,
    first_visited_at INTEGER NOT NULL,
    last_visited_at INTEGER NOT NULL,
    PRIMARY KEY (h3_index)
);
CREATE INDEX idx_hex_resolution ON user_hex_cells(h3_resolution);
```

Какую схему выбрать -- решается в FogRidePersistence. `HexCellSet` должен уметь загружаться из обеих.

### Что пакет НЕ делает

- Не хранит (нет GRDB).
- Не синхронизирует (нет CloudKit).
- Не знает про Trip/User/Achievement.
- Не содержит UI.

### Тесты

- Unit: compaction round-trip (compact -> uncompact == original).
- Stress: вставка 100k случайных ячеек -- время, память.
- Property-based: `holes(in: bbox, detail: r)` для detail <= resolution должен покрыть все visited-ячейки.
- Benchmark: full multipolygon rebuild для 1k / 10k / 100k ячеек (target: 10k < 50ms).

### Зависимости

- HexCore

Используется в: [[MapKit|MapFogOfWar]] (через адаптер), [[Domain|FogCalculator]]

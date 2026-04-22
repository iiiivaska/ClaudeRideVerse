# FogRide — Архитектура, часть 2: HexKit и граница Domain/Features

Это продолжение ТЗ по модульной архитектуре. Первая часть описывала структуру пакетов и детально — `MapKit` и `LocationKit`. Здесь разбираем `HexKit` (два нетривиальных пакета про H3) и показываем, где именно проходит граница между переиспользуемыми пакетами и бизнес-логикой FogRide — куда положить `Trip`, `FogCalculator`, `AchievementEngine`, и как они разговаривают с UI.

---

## Часть A: HexKit

### Почему два пакета, а не один

Соблазн — один `HexKit` со всем внутри. Причины разделить:

1. **`HexCore` — тонкая обёртка над C-библиотекой H3 через SwiftyH3.** Она должна быть максимально стабильной, с минимумом логики. Хочется, чтобы её можно было перетащить в любой проект, где есть H3, не затащив с собой наш специфический код multipolygon-слияния.
2. **`HexGeometry` — алгоритмы поверх H3.** Compaction, MultiPolygon-операции, итераторы по сетке — это уже мнение, как именно использовать H3 для fog of war и аналитики. Здесь допустимы тяжёлые зависимости (GEOS для полигонной алгебры, если понадобится), оптимизации, кеши.
3. **Разные ритмы изменений.** `HexCore` меняется только при апгрейде H3 (раз в год). `HexGeometry` будет дописываться постоянно, пока дорабатываем fog-механику.

---

### Пакет 1: `HexCore`

**Одной фразой:** строго-типизированная Swift-обёртка над H3, которая делает H3-индексы first-class Swift-объектами и защищает от путаницы resolutions.

#### Зачем вообще обёртка над SwiftyH3

SwiftyH3 сам — хорошая библиотека, но её API — это прямой маппинг C-функций: `latLngToCell(lat, lng, resolution) -> UInt64`. Это рабочий, но небезопасный API: `UInt64` не несёт информации о resolution, легко перепутать индексы разных уровней, нет защиты от невалидных значений. `HexCore` добавляет слой типов, который делает эти ошибки невозможными на этапе компиляции.

Плюс — SwiftyH3 может когда-нибудь стать abandonware. Если мы пишем свой код против обёртки, миграция на другую H3-библиотеку (или собственные bindings к C) сводится к одному файлу.

#### Публичный API

```swift
/// Resolution строго типизирована через enum с associated значениями площади.
public enum HexResolution: Int, Sendable, CaseIterable, Comparable {
    case r0 = 0   // ~1107 km edge
    case r1 = 1
    case r2 = 2
    case r3 = 3
    case r4 = 4
    case r5 = 5   // ~8.5 km edge
    case r6 = 6
    case r7 = 7
    case r8 = 8   // ~461 m edge
    case r9 = 9   // ~174 m edge — дефолт FogRide
    case r10 = 10
    case r11 = 11
    case r12 = 12
    case r13 = 13
    case r14 = 14
    case r15 = 15  // ~0.5 m edge
    
    public var averageEdgeMeters: Double { ... }
    public var averageAreaSquareMeters: Double { ... }
    public var averageDiameterMeters: Double { ... }
    
    public static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

/// H3-индекс, параметризованный resolution через phantom type было бы идеально,
/// но H3 хранит resolution внутри UInt64 — делаем runtime-валидацию.
public struct HexCell: Hashable, Sendable, CustomStringConvertible {
    public let index: UInt64
    public let resolution: HexResolution
    
    /// Создать из координаты. Никогда не fails для валидных lat/lng.
    public init(coordinate: CLLocationCoordinate2D, resolution: HexResolution)
    
    /// Попытаться создать из сырого UInt64. Возвращает nil для pentagons
    /// в strict-режиме или для невалидных индексов.
    public init?(index: UInt64, strict: Bool = false)
    
    public var center: CLLocationCoordinate2D { get }
    public var boundary: [CLLocationCoordinate2D] { get }  // 6 вершин, 5 для pentagon
    public var isPentagon: Bool { get }
    
    public var description: String { get }  // "8928308280fffff"
}

/// Операции над ячейкой.
extension HexCell {
    /// k-ring: все ячейки в пределах k шагов (включая саму).
    public func neighbors(within k: Int) -> Set<HexCell>
    
    /// Только непосредственные соседи (k=1, исключая саму).
    public var immediateNeighbors: Set<HexCell> { get }
    
    /// Подняться на родительский resolution.
    public func parent(at resolution: HexResolution) -> HexCell?
    
    /// Опуститься на дочерний resolution — вернёт 7 ячеек (или 6 для pentagon).
    public func children(at resolution: HexResolution) -> Set<HexCell>
    
    /// Расстояние в ячейках (grid distance). Nil если между ячейками
    /// пересекаются pentagons (H3 не гарантирует metric в таких случаях).
    public func gridDistance(to other: HexCell) -> Int?
}

/// Batch-операции. Часто эффективнее, чем поэлементно.
public enum HexCellBatch {
    /// Конвертировать массив координат в ячейки с дедупликацией.
    public static func cells(
        for coordinates: [CLLocationCoordinate2D],
        resolution: HexResolution
    ) -> Set<HexCell>
    
    /// "Растворить" ячейки в multipolygon — контур объединённой области.
    /// Это тонкая обёртка над H3 cellsToMultiPolygon.
    public static func boundary(of cells: Set<HexCell>) -> HexMultiPolygon
}

/// Результат cellsToMultiPolygon. Каждый полигон — outer ring + список holes.
public struct HexMultiPolygon: Sendable {
    public struct Polygon: Sendable {
        public let outer: [CLLocationCoordinate2D]
        public let holes: [[CLLocationCoordinate2D]]
    }
    public let polygons: [Polygon]
}

/// Ошибки, которые могут возникнуть в операциях над H3.
public enum HexError: Error {
    case invalidCoordinate
    case resolutionMismatch(expected: HexResolution, got: HexResolution)
    case antimeridianCrossing
    case pentagonEncountered
}
```

#### Ключевые обязанности

- **Типобезопасность resolution.** Методы вроде `parent(at:)` принимают `HexResolution`, а не `Int`. Если попытаться вызвать `parent(at: .r9)` на ячейке r9, получится compile-time sensible поведение (возвращает nil или саму себя — решается документацией).
- **Инкапсуляция pentagons.** В каждом resolution есть 12 «пентагонов» — ячеек с 5 соседями вместо 6. `HexCell.isPentagon` явно их маркирует; `gridDistance` возвращает `nil`, если путь затронул pentagon. Это защищает от скрытых багов в алгоритмах.
- **Известный баг антимеридиана в `cellsToMultiPolygon`** — пакет ловит его, возвращая `HexError.antimeridianCrossing` через throwing-вариант `boundary(of:)`. Для FogRide это теоретический кейс (кросс-океанские маршруты), но поле нужно закрыть.
- **Sendable everywhere.** Все структуры — `Sendable`, чтобы спокойно передавать между акторами в Swift 6 concurrency mode.

#### Что пакет НЕ делает

- **Не рендерит.** Никаких MapLibre-зависимостей, никакого SwiftUI.
- **Не знает про fog of war.** Просто даёт операции над H3.
- **Не хранит.** Никакой GRDB, никакого CoreData — это обязанность `PersistenceCore` и уровня приложения.
- **Не компактует.** Compaction по-хитрому — это `HexGeometry`.

#### Тесты

- Unit для каждой операции с фиксированными индексами (берём из официальных тестов H3).
- Property-based тесты: `cell.parent(at: r).children(at: cell.resolution).contains(cell)` должно быть true для любой валидной ячейки.
- Тест на пентагонах: для 12 известных индексов r0 — `isPentagon == true`, соседей ровно 5.

---

### Пакет 2: `HexGeometry`

**Одной фразой:** алгоритмы над наборами ячеек — compaction по zoom, эффективные multipolygon-операции, итераторы по сетке, адаптеры для `MapFogOfWar`.

#### Ключевые сценарии

1. **Хранение и загрузка миллионов visited-ячеек.** Нельзя хранить 100k raw ячеек r9 в памяти — через compaction это ~10k на разных resolutions.
2. **Запрос visited для viewport.** Карта тянет: «дай мне все visited в этом bbox для zoom 12». Нужно быстро.
3. **Инкрементальное добавление ячейки.** Каждая GPS-точка → возможно, новая ячейка открылась. Структура должна обновляться без полного пересчёта.
4. **Fog-of-war адаптер.** Реализовать протокол `VisitedCells` из `MapFogOfWar`.

#### Публичный API

```swift
/// Основная коллекция — эффективное in-memory представление ячеек
/// с поддержкой компакции.
public final class HexCellSet: Sendable {
    /// Конструктор для построения с нуля. Добавление ячейки O(1) в среднем.
    public init()
    
    /// Конструктор из compacted-снапшота (например, загруженного из GRDB).
    public init(compactedSnapshot: CompactedHexSnapshot)
    
    // MARK: - Mutations
    
    /// Добавить ячейку. Thread-safe через actor-isolation.
    @discardableResult
    public func insert(_ cell: HexCell) async -> InsertResult
    
    /// Batch-вставка — быстрее, чем в цикле.
    public func insert(contentsOf cells: some Sequence<HexCell>) async
    
    // MARK: - Queries
    
    public func contains(_ cell: HexCell) async -> Bool
    public var count: Int { get async }
    
    /// Ячейки в указанном bbox с нужным уровнем детализации.
    /// Если detail крупнее чем native r9 — возвращаются уже компактизованные родители.
    public func cells(
        in bbox: MapBBox,
        detail: HexResolution
    ) async -> Set<HexCell>
    
    /// Многоугольники дыр в тумане для viewport — главный метод для MapFogOfWar.
    public func holes(
        in bbox: MapBBox,
        detail: HexResolution
    ) async -> [[CLLocationCoordinate2D]]
    
    /// Монотонно растущий номер — для инвалидации кешей в UI.
    public var revision: Int { get async }
    
    // MARK: - Persistence
    
    /// Снапшот для сохранения на диск.
    public func compactedSnapshot() async -> CompactedHexSnapshot
    
    public enum InsertResult: Sendable {
        case inserted       // ячейка была новой
        case alreadyPresent // уже была
        case upgraded       // произошла компактизация родителя
    }
}

/// Сериализуемый снапшот компактизованного набора.
public struct CompactedHexSnapshot: Codable, Sendable {
    /// Ячейки на разных resolutions, образующие минимальное покрытие.
    public let compactedCells: [HexCell]
    public let version: Int
}

/// Compaction-алгоритмы как pure functions (для тестируемости).
public enum HexCompaction {
    /// Стандартный H3 compact: если все 7 детей ячейки-родителя присутствуют,
    /// они заменяются на родителя. Рекурсивно.
    public static func compact(_ cells: Set<HexCell>) -> Set<HexCell>
    
    /// Обратная операция: разложить compacted-набор до единого resolution.
    public static func uncompact(
        _ cells: Set<HexCell>,
        to resolution: HexResolution
    ) -> Set<HexCell>
    
    /// Lossy-компактизация по zoom для viewport-рендеринга.
    /// Если доля открытых детей родителя ≥ threshold — считать родителя открытым.
    public static func lossyCompact(
        _ cells: Set<HexCell>,
        toResolution targetResolution: HexResolution,
        threshold: Double  // 0..1, например 0.7
    ) -> Set<HexCell>
}

/// Итераторы по сетке для специальных сценариев.
public enum HexGridIterator {
    /// Все ячейки внутри полигона (для bbox-запросов, тулов импорта).
    public static func cells(
        in polygon: [CLLocationCoordinate2D],
        resolution: HexResolution
    ) -> AsyncStream<HexCell>
    
    /// Ячейки вдоль линии (при импорте GPX — заполнение разрывов в треке).
    public static func cells(
        along line: [CLLocationCoordinate2D],
        resolution: HexResolution
    ) -> [HexCell]
}

/// Адаптер для MapFogOfWar.VisitedCells.
public struct HexCellSetFogAdapter: VisitedCells {
    public init(cellSet: HexCellSet)
    
    public func holes(
        in bbox: MapBBox,
        detail: FogDetailLevel
    ) -> [[CLLocationCoordinate2D]] { ... }
    
    public var revision: Int { ... }
}
```

#### Стратегия хранения в `HexCellSet`

Внутри — двухуровневая структура:

- **Hot layer**: `Set<HexCell>` на native resolution (r9 по умолчанию) для последних N изменений. O(1) вставка, быстрый contains.
- **Cold layer**: compacted-дерево родительских ячеек. Обновляется батчами или по таймеру (раз в ~30 секунд или при достижении threshold в hot layer).
- **Bbox index**: R-tree или простой grid index поверх `(bbox → cells)` для быстрых viewport-запросов.

Когда в hot layer попадают все 7 детей какого-то r8-родителя, они схлопываются в одну r8-ячейку в cold layer.

#### Adaptive compaction для рендеринга

Сценарий: карта на zoom 10, viewport охватывает 50 км. Если бы мы отрисовывали всё в r9, это тысячи полигонов. Стратегия:

- z ≥ 13 → `detail: .r9` (native).
- z 11–12 → `detail: .r8` (через `lossyCompact` с threshold 0.5).
- z 9–10 → `detail: .r7`.
- z ≤ 8 → `detail: .r6` (или один сплошной polygon для всего континента).

`lossyCompact` — не идеален математически (hex не делится ровно по resolution-границам), но визуально это незаметно при zoom out.

#### Multipolygon — эффективная реализация

`HexCellBatch.boundary` из `HexCore` использует H3 native `cellsToMultiPolygon`. Это работает, но для очень больших наборов (десятки тысяч ячеек) он медленный. В `HexGeometry` добавляем:

```swift
/// Кешированный multipolygon-builder, который инкрементально обновляется
/// при добавлении/удалении ячеек.
public actor IncrementalMultiPolygonBuilder {
    public init()
    public func add(_ cell: HexCell) async
    public func remove(_ cell: HexCell) async
    public func currentBoundary() async -> HexMultiPolygon
}
```

Для MVP можно не делать инкрементальный — полный пересчёт раз в секунду на set из 10k ячеек укладывается в 50ms. Но поле для оптимизации оставляем.

#### Fog-адаптер

`HexCellSetFogAdapter` — это мост между `HexCellSet` и протоколом `VisitedCells` из `MapFogOfWar`. Единственная его работа — конвертировать `FogDetailLevel.auto(zoom:)` в `HexResolution` через таблицу выше и делегировать запрос в `HexCellSet`.

Этот адаптер важен архитектурно: он живёт в `HexGeometry`, который знает и про `HexCell`, и про `MapFogOfWar`. Таким образом **`MapFogOfWar` не зависит от H3 напрямую, а `HexGeometry` не зависит от MapLibre** — зависимость идёт через общий контракт `VisitedCells`. Это позволяет тестировать `HexCellSet` без MapLibre и `MapFogOfWar` — без H3.

#### Persistence-схема для GRDB

`HexGeometry` не тянет GRDB в зависимости, но определяет `CompactedHexSnapshot: Codable` и удобные методы. Конкретная таблица GRDB живёт в `FogRidePersistence`:

```sql
-- В FogRidePersistence
CREATE TABLE user_hex_snapshots (
    id INTEGER PRIMARY KEY,
    snapshot_blob BLOB NOT NULL,  -- encoded CompactedHexSnapshot
    updated_at INTEGER NOT NULL,
    revision INTEGER NOT NULL
);

-- Альтернативно, для сценариев с sharing: плоская таблица, которую проще
-- инкрементально обновлять:
CREATE TABLE user_hex_cells (
    h3_index INTEGER NOT NULL,
    h3_resolution INTEGER NOT NULL,
    first_visited_at INTEGER NOT NULL,
    last_visited_at INTEGER NOT NULL,
    PRIMARY KEY (h3_index)
);
CREATE INDEX idx_hex_resolution ON user_hex_cells(h3_resolution);
```

Какую схему выбрать — решается в `FogRidePersistence`, но `HexCellSet` должен уметь загружаться из обеих (через два разных init-метода).

#### Что пакет НЕ делает

- Не хранит (нет GRDB).
- Не синхронизирует (нет CloudKit).
- Не знает про Trip/User/Achievement.
- Не содержит UI.

#### Тесты

- Unit: compaction round-trip (compact → uncompact == original).
- Stress: вставка 100k случайных ячеек — время, память.
- Property-based: `holes(in: bbox, detail: r)` для detail ≤ resolution должен вернуть полигоны, покрывающие все visited-ячейки.
- Benchmark: full multipolygon rebuild для 1k / 10k / 100k ячеек (target: 10k < 50ms).

---

## Часть B: граница Domain ↔ Features ↔ Packages

### Три слоя и строгие правила

```
┌─────────────────────────────────────────────────────────┐
│  App: FogRideApp                                        │
│  ─ composition root, DI, deep links, app lifecycle      │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Features/*                                             │
│  ─ SwiftUI Views + feature-specific @Observable models  │
│  ─ знают про Domain, могут тянуть Packages для UI       │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Domain/                                                │
│  ├ FogRideModels       — Trip, Bike, Achievement, etc.  │
│  ├ FogRidePersistence  — SwiftData + GRDB хранилища     │
│  └ FogRideServices     — TripRecorder, FogCalculator    │
│  Знает про Packages, НЕ знает про UI и про Features     │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│  Packages/*  (MapCore, HexCore, LocationRecording, ...) │
│  Не знают ни про Domain, ни про Features, ни про App    │
└─────────────────────────────────────────────────────────┘
```

**Правило 1:** пакеты никогда не импортируют `FogRideModels`. Пакет `LocationRecording` оперирует `RawLocation`, а не `TripPoint` из Domain.

**Правило 2:** `Domain` никогда не импортирует SwiftUI. Если `@Observable` класс в Domain — это нормально (Observation framework — Foundation-адъюнкт, не UI). Но никаких `View`, `Color`, `Image`.

**Правило 3:** `Features` импортируют Domain и нужные Packages для UI (MapCore, DesignSystem). Они могут видеть `LocationRecorder`, но в норме общаются с ним через `TripRecorder` из Domain.

**Правило 4:** один feature-модуль не импортирует другой feature-модуль. Если `RecordingFeature` должен после сохранения поездки показать `TripDetailFeature`, это решает роутер на уровне App.

---

### Domain/FogRideModels

Чистые value-types и @Model-классы, описывающие доменные сущности. Никаких сервисов, никаких use-cases — только данные.

```swift
// FogRideModels/Trip.swift
@Model
public final class Trip {
    @Attribute(.unique) public var id: UUID
    public var name: String
    public var startedAt: Date
    public var endedAt: Date?
    public var distanceMeters: Double
    public var movingDurationSeconds: TimeInterval
    public var totalDurationSeconds: TimeInterval
    public var elevationGainMeters: Double
    public var elevationLossMeters: Double
    public var averageSpeedKmh: Double
    public var maxSpeedKmh: Double
    public var newHexCount: Int
    
    /// Simplified polyline для списков и CloudKit (2KB max).
    /// Полные точки — в GRDB, не синхронизируются.
    @Attribute(.externalStorage) public var summaryPolyline: Data
    
    /// Thumbnail для списка — рендерим при сохранении.
    @Attribute(.externalStorage) public var thumbnailPNG: Data?
    
    /// Имя файла с raw-точками в GRDB-хранилище.
    public var trackFileReference: String
    
    @Relationship public var bike: Bike?
    
    public init(...) { ... }
}

// FogRideModels/Bike.swift
@Model
public final class Bike { ... }

// FogRideModels/Achievement.swift
@Model
public final class Achievement { ... }

// FogRideModels/UserStats.swift
@Model
public final class UserStats {
    public var totalDistance: Double
    public var totalRides: Int
    public var totalHexCount: Int
    public var eddingtonNumber: Int
    public var maxSquareSide: Int
    public var maxClusterSize: Int
    // обновляется FogCalculator после каждой поездки
}
```

**Что в модели и что не в модели:**

- В модели — только **состояние**: поля, relationships, уникальные индексы.
- Не в модели — логика сохранения, миграции, computed aggregations. Всё это — в `FogRidePersistence` и `FogRideServices`.

**Computed properties — осторожно.** `trip.elevationGainFeet: Double { elevationGainMeters * 3.28 }` — ок, это pure. `trip.thumbnail: UIImage { ... }` — **не ок**, UIKit в Domain запрещён.

---

### Domain/FogRidePersistence

Инкапсулирует конкретные технологии хранения (SwiftData + GRDB) за repository-like интерфейсами.

```swift
// FogRidePersistence/TripRepository.swift
public protocol TripRepository: Sendable {
    func save(_ trip: Trip, points: [RawLocation]) async throws
    func load(id: UUID) async throws -> Trip
    func loadPoints(for tripID: UUID) async throws -> [RawLocation]
    func list(sortedBy: TripSortOrder, limit: Int) async throws -> [Trip]
    func delete(id: UUID) async throws
    
    /// Observation — поток изменений для SwiftUI.
    func observeList() -> AsyncStream<[Trip]>
}

public final class DefaultTripRepository: TripRepository {
    private let swiftDataContainer: ModelContainer
    private let pointsDatabase: DatabaseWriter  // GRDB
    
    public init(swiftDataContainer: ModelContainer, pointsDatabase: DatabaseWriter)
    
    // реализация, которая сохраняет метаданные в SwiftData,
    // а raw-точки — в GRDB. Транзакционно.
}

// FogRidePersistence/HexSnapshotRepository.swift
public protocol HexSnapshotRepository: Sendable {
    func loadLatest() async throws -> CompactedHexSnapshot?
    func save(_ snapshot: CompactedHexSnapshot) async throws
}
```

**Почему TripRepository — protocol:** тесты. `FogRideServices.TripRecorder` в тестах получает mock-репозиторий без реальной SwiftData/GRDB.

**Swift 6 gotcha:** `ModelContext` не `Sendable`. Repository работает внутри ограниченного актора и возвращает только value-types / `@Model`-классы, которые уже detached от контекста (через `.id` и повторный fetch).

---

### Domain/FogRideServices

Это «сердце приложения» — доменные сервисы, которые оркестрируют пакеты. Единственное место, где встречаются `LocationRecorder` + `HexCellSet` + `MetricsAccumulator` и превращаются в живой процесс записи поездки.

```swift
// FogRideServices/TripRecorder.swift
@Observable
@MainActor  // публичные мутации на main; тяжёлая работа — в вложенных акторах
public final class TripRecorder {
    public enum State: Sendable {
        case idle
        case recording(startedAt: Date)
        case paused(pausedAt: Date)
        case finishing
        case failed(Error)
    }
    
    public private(set) var state: State = .idle
    public private(set) var liveMetrics: LiveMetrics = .zero
    public private(set) var newHexesThisRide: Int = 0
    
    private let locationRecorder: LocationRecorder
    private let accuracyGate: AccuracyGate
    private let kalman: KalmanFilter1D?
    private let metricsAccumulator: MetricsAccumulator
    private let motionMonitor: MotionActivityMonitor
    private let altimeter: AltimeterService  // тонкая обёртка над CMAltimeter
    private let hexCellSet: HexCellSet
    private let repository: TripRepository
    
    private var collectedPoints: [RawLocation] = []
    private var recordingTask: Task<Void, Never>?
    
    public init(...) { /* DI */ }
    
    public func startRide(name: String?, bike: Bike?) async throws {
        guard case .idle = state else { throw TripRecorderError.alreadyRecording }
        state = .recording(startedAt: Date())
        
        recordingTask = Task {
            do {
                let stream = await locationRecorder.start()
                    .gated(by: accuracyGate)
                
                for try await rawLocation in stream {
                    await handle(location: rawLocation)
                }
            } catch {
                state = .failed(error)
            }
        }
    }
    
    public func pause() async { ... }
    public func resume() async { ... }
    
    public func finishRide() async throws -> Trip {
        state = .finishing
        recordingTask?.cancel()
        
        let analysis = TrackAnalyzer.analyze(
            points: collectedPoints,
            altitudes: nil
        )
        let simplified = LineSimplify.simplify(collectedPoints, tolerance: 5)
        let polylineData = PolylineEncoder.encode(simplified)
        let thumbnail = await ThumbnailRenderer.render(simplified)
        
        let trip = Trip(
            id: UUID(),
            startedAt: ...,
            distanceMeters: analysis.totalDistance,
            // ...
            newHexCount: newHexesThisRide,
            summaryPolyline: polylineData,
            thumbnailPNG: thumbnail.pngData(),
            trackFileReference: UUID().uuidString
        )
        
        try await repository.save(trip, points: collectedPoints)
        
        state = .idle
        resetCounters()
        return trip
    }
    
    private func handle(location: RawLocation) async {
        collectedPoints.append(location)
        await metricsAccumulator.ingest(location)
        liveMetrics = await metricsAccumulator.snapshot
        
        let cell = HexCell(coordinate: location.coordinate, resolution: .r9)
        let ring = cell.neighbors(within: 1)  // сглаживание GPS-шума
        
        for c in ring {
            let result = await hexCellSet.insert(c)
            if case .inserted = result {
                newHexesThisRide += 1
            }
        }
    }
}

// FogRideServices/FogCalculator.swift
/// Вычисляет и обновляет агрегаты UserStats: Eddington, Max Square, Max Cluster.
public actor FogCalculator {
    public init(repository: HexSnapshotRepository, statsRepository: UserStatsRepository)
    
    /// Пересчитать всё с нуля. Вызывается в BGProcessingTask раз в сутки.
    public func recomputeAll() async throws
    
    /// Инкрементальное обновление после поездки — дешевле, чем полный пересчёт.
    public func updateAfterTrip(_ trip: Trip, newCells: Set<HexCell>) async throws
}

// FogRideServices/AchievementEngine.swift
/// Проверяет, не разблокировал ли пользователь ачивку после изменения стейта.
public actor AchievementEngine {
    public init(repository: AchievementRepository)
    
    public func evaluate(after event: DomainEvent) async throws -> [Achievement]
}

public enum DomainEvent: Sendable {
    case tripFinished(Trip)
    case hexCountCrossed(Int)
    case maxSquareGrew(side: Int)
}
```

**Ключевые моменты:**

1. **`TripRecorder` — единственный, кто соединяет пакеты.** Views не видят `LocationRecorder` напрямую. Если появится новая фича «запись тренировки с автопаузой по пульсу», она расширяет `TripRecorder`, а не лезет в `LocationRecording`.
2. **События вместо прямых вызовов.** `AchievementEngine` слушает `DomainEvent`, а не вызывается руками из `TripRecorder`. Это позволяет добавлять новых подписчиков (например, аналитика) без изменения recorder'а.
3. **Акторы для всего stateful.** `FogCalculator`, `AchievementEngine` — акторы; `TripRecorder` — `@MainActor` потому что его state напрямую биндится в UI.

---

### Features/* — анатомия feature-модуля

Пример: `RecordingFeature`. Структура типового пакета:

```
Features/RecordingFeature/
├── Package.swift
├── Sources/
│   └── RecordingFeature/
│       ├── RecordingView.swift           # корневой SwiftUI View
│       ├── RecordingViewModel.swift      # @Observable view model
│       ├── Components/
│       │   ├── LiveHUD.swift
│       │   ├── HexCounterView.swift
│       │   ├── RecordButton.swift
│       │   └── MapWithTrackLayer.swift
│       ├── Preview/
│       │   └── MockTripRecorder.swift    # для preview/тестов
│       └── Localization/
│           └── Localizable.xcstrings
└── Tests/
    └── RecordingFeatureTests/
```

**`Package.swift` typical:**

```swift
// swift-tools-version: 6.2
let package = Package(
    name: "RecordingFeature",
    platforms: [.iOS("26.0")],
    products: [.library(name: "RecordingFeature", targets: ["RecordingFeature"])],
    dependencies: [
        .package(path: "../../Domain/FogRideModels"),
        .package(path: "../../Domain/FogRideServices"),
        .package(path: "../../Packages/MapCore"),
        .package(path: "../../Packages/MapOverlays"),
        .package(path: "../../Packages/MapFogOfWar"),
        .package(path: "../../Packages/HexGeometry"),
        .package(path: "../../Packages/DesignSystem"),
    ],
    targets: [ ... ]
)
```

Feature НЕ тянет `LocationRecording` напрямую. Он работает с `TripRecorder` из `FogRideServices`, который уже содержит `LocationRecorder` внутри.

Единственное исключение — если feature нужен какой-то примитив из пакета (например, `RawLocation` для отображения текущих координат). Тогда нужный пакет добавляется в dependencies напрямую.

---

### View → ViewModel → Service

```swift
// Features/RecordingFeature/RecordingViewModel.swift
@Observable
@MainActor
public final class RecordingViewModel {
    private let tripRecorder: TripRecorder  // инъекция через init
    
    public var recordingState: TripRecorder.State { tripRecorder.state }
    public var metrics: LiveMetrics { tripRecorder.liveMetrics }
    public var newHexes: Int { tripRecorder.newHexesThisRide }
    
    public init(tripRecorder: TripRecorder) {
        self.tripRecorder = tripRecorder
    }
    
    public func onRecordTap() {
        Task {
            switch tripRecorder.state {
            case .idle:
                try? await tripRecorder.startRide(name: nil, bike: nil)
            case .recording:
                try? await tripRecorder.finishRide()
            case .paused:
                await tripRecorder.resume()
            default: break
            }
        }
    }
}

// Features/RecordingFeature/RecordingView.swift
public struct RecordingView: View {
    @State private var viewModel: RecordingViewModel
    @Environment(\.fogMapStyle) private var mapStyle
    
    public init(viewModel: RecordingViewModel) {
        self._viewModel = State(wrappedValue: viewModel)
    }
    
    public var body: some View {
        ZStack {
            FogMap(camera: .constant(...), styleURL: mapStyle) {
                FogOfWarLayer(visited: /* adapter */)
                TrackPolyline(id: "current", coordinates: ...)
            }
            
            VStack {
                LiveHUD(metrics: viewModel.metrics, hexCount: viewModel.newHexes)
                Spacer()
                RecordButton(state: viewModel.recordingState, action: viewModel.onRecordTap)
            }
            .padding()
        }
    }
}
```

**Observations:**

- View знает про `RecordingViewModel` и `FogMap`. Не знает про `LocationRecorder`, `HexCellSet`, GRDB.
- `RecordingViewModel` — обёртка над `TripRecorder`, которая экспонирует state в удобном для SwiftUI виде и группирует user-intents (`onRecordTap`).
- Environment (`mapStyle`) пробрасывается сверху — из `App`-уровня.

---

### Composition root: как это всё собирается в `App`

```swift
// App/FogRideApp/FogRideApp.swift
@main
struct FogRideApp: App {
    // Все stateful-сервисы создаются здесь и живут на протяжении всего
    // жизненного цикла приложения.
    @State private var services = AppServices()
    
    var body: some Scene {
        WindowGroup {
            RootNavigator()
                .environment(\.services, services)
                .environment(\.fogMapStyle, StadiaStyles.outdoorsURL)
        }
    }
}

@Observable
@MainActor
final class AppServices {
    let swiftDataContainer: ModelContainer
    let pointsDatabase: DatabaseWriter
    let tripRepository: TripRepository
    let hexRepository: HexSnapshotRepository
    let hexCellSet: HexCellSet
    let tripRecorder: TripRecorder
    let fogCalculator: FogCalculator
    let achievementEngine: AchievementEngine
    
    init() {
        // 1. Поднимаем persistence
        swiftDataContainer = try! ModelContainer(for: Trip.self, Bike.self, ...)
        pointsDatabase = try! DatabaseQueue(path: Paths.tracksDB)
        try! Migrations.run(on: pointsDatabase)
        
        tripRepository = DefaultTripRepository(
            swiftDataContainer: swiftDataContainer,
            pointsDatabase: pointsDatabase
        )
        hexRepository = DefaultHexSnapshotRepository(database: pointsDatabase)
        
        // 2. Восстанавливаем состояние hex-сета
        let snapshot = try? await hexRepository.loadLatest()
        hexCellSet = snapshot.map { HexCellSet(compactedSnapshot: $0) } ?? HexCellSet()
        
        // 3. Создаём сервисы
        tripRecorder = TripRecorder(
            locationRecorder: LocationRecorder(configuration: .cycling),
            accuracyGate: AccuracyGate(),
            kalman: nil,  // выключен по умолчанию
            metricsAccumulator: MetricsAccumulator(altimeter: .fused),
            motionMonitor: MotionActivityMonitor(),
            altimeter: AltimeterService(),
            hexCellSet: hexCellSet,
            repository: tripRepository
        )
        fogCalculator = FogCalculator(...)
        achievementEngine = AchievementEngine(...)
    }
}

// Environment ключ
private struct ServicesKey: EnvironmentKey {
    static let defaultValue: AppServices = ...  // crash preview если не переопределён
}

extension EnvironmentValues {
    var services: AppServices {
        get { self[ServicesKey.self] }
        set { self[ServicesKey.self] = newValue }
    }
}
```

Feature-view получает нужный сервис из `Environment`:

```swift
struct RecordingScreen: View {
    @Environment(\.services) private var services
    
    var body: some View {
        RecordingView(viewModel: RecordingViewModel(tripRecorder: services.tripRecorder))
    }
}
```

**Альтернатива — DI-контейнер через Factory/Swinject.** Для соло-разработчика избыточно; `Environment` работает и проще в тестах.

---

### Где хранятся какие вещи — таблица-шпаргалка

| Сущность | Где живёт | Почему там |
|---|---|---|
| `CLLocation` обёртка (`RawLocation`) | `LocationRecording` | Primitive, используемый многими пакетами |
| `HexCell`, `HexResolution` | `HexCore` | H3-примитив |
| `HexCellSet` | `HexGeometry` | Collection поверх H3 |
| `VisitedCells` protocol | `MapFogOfWar` | Контракт для fog rendering |
| `MapCamera`, `MapBBox` | `MapCore` | Map primitives |
| `Trip`, `Bike`, `Achievement` | `FogRideModels` | Domain entities |
| `TripRepository` protocol | `FogRidePersistence` | Domain contract |
| `DefaultTripRepository` impl | `FogRidePersistence` | Конкретная SwiftData+GRDB реализация |
| `TripRecorder` | `FogRideServices` | Соединяет пакеты в доменный процесс |
| `FogCalculator` | `FogRideServices` | Доменная логика аналитики |
| `AchievementEngine` | `FogRideServices` | Доменная логика |
| `RecordingView`, `RecordingViewModel` | `Features/RecordingFeature` | UI-слой |
| `AppServices` (composition root) | `App/FogRideApp` | Зависит от всего |
| Цвета, шрифты, typography | `DesignSystem` | Общие UI tokens |
| SwiftData schema declaration | `FogRideModels` (через @Model) + `FogRidePersistence` (container setup) | @Model в моделях, подъём контейнера — в persistence |

---

### Как это масштабируется на новые фичи

**Сценарий 1:** добавляем Apple Watch companion (фаза 5).
- Переиспользуем `LocationRecording`, `LocationFiltering`, `HexCore`, `HexGeometry`, `CyclingSensors`, `WorkoutKit`.
- Новый feature-модуль `WatchCompanion` (в отдельном watchOS-таргете).
- `Domain` — тот же, общий через `WCSession`.
- Новых пакетов не создаём.

**Сценарий 2:** добавляем публичный heatmap (фаза 3).
- Новый пакет `HeatmapKit` (рендер heatmap-тайлов через MapLibre).
- Новый feature-модуль `CommunityHeatmapFeature`.
- Новый doменный сервис `HeatmapService` в `FogRideServices`.
- Возможно — новый сетевой слой `FogRideBackend` в `Domain/`.

**Сценарий 3:** хотим выпустить отдельное walking-приложение на этих же пакетах.
- Создаём новый App-таргет с другим bundle ID.
- Переиспользуем все пакеты (MapCore, LocationRecording, HexCore, HexGeometry, MapFogOfWar).
- НЕ переиспользуем `Domain/*` и `Features/*` — у них своя доменная модель.
- Это и есть главный бонус от дисциплинированного деления.

---

### Антипаттерны, которых избегаем

1. **«God-пакет» `FogRideKit`** со всем сразу — теряем преимущества модульности.
2. **Feature тянет другой feature.** Если `TripDetailFeature` нужно поделиться кнопкой с `RecordingFeature`, кнопка выносится в `DesignSystem`.
3. **Package импортирует Domain.** Это инверсия зависимостей — пакет становится неперенсимым. Если нужен общий тип — поднимаем его в пакет (через generics или protocol), не в Domain.
4. **View обращается к repository напрямую.** View → ViewModel → Service → Repository. Три слоя абстракции ниже — это плата за тестируемость.
5. **SwiftUI `@Query` для GPS-точек.** `@Query` материализует весь dataset; для треков из 10k+ точек это крах. Используем GRDB observation через async stream в ViewModel.
6. **Domain-событие с UI-контекстом.** `DomainEvent.achievementUnlocked(achievement, showToast: Bool)` — плохо; `showToast` — решение UI, не Domain.

---

### Чеклист перед началом кодирования

- [ ] Xcode-workspace создан, все пакеты видят друг друга.
- [ ] `HexCore` + `HexGeometry` написаны и покрыты тестами (2–3 недели).
- [ ] `LocationRecording` + `LocationFiltering` + `LocationAnalysis` написаны с fixture-тестами GPS (3 недели).
- [ ] `MapCore` отрисовывает Stadia Outdoors карту, реагирует на камеру (1 неделя).
- [ ] `MapOverlays` рисует polyline из fixture-трека (1 неделя).
- [ ] `MapFogOfWar` + адаптер из `HexGeometry` рисует fog на прототипе (1–2 недели).
- [ ] `FogRideModels` + `FogRidePersistence` настроены, миграции работают.
- [ ] `TripRecorder` собран в `FogRideServices`, покрыт тестами с моками.
- [ ] `RecordingFeature` — первый полноценный SwiftUI-экран, подключённый к `TripRecorder`.
- [ ] Composition root в `FogRideApp` собран.
- [ ] Первая реальная поездка записана end-to-end.

На этом фундаменте строятся остальные features, новые пакеты добавляются по мере появления требований.

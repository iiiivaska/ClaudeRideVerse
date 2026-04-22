# Domain -- доменный слой FogRide
> FogRideModels, FogRidePersistence, FogRideServices. Модели данных, хранилища, бизнес-сервисы и composition root.

Domain знает про Packages, но **НЕ знает про UI и Features**. Использует [[MapVerse]], [[LocationKit]], [[HexKit]] через их публичные API.

---

## Domain/FogRideModels

Чистые value-types и `@Model`-классы, описывающие доменные сущности. Никаких сервисов, никаких use-cases -- только данные.

### Trip

```swift
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
    /// Полные точки -- в GRDB, не синхронизируются.
    @Attribute(.externalStorage) public var summaryPolyline: Data
    
    /// Thumbnail для списка -- рендерим при сохранении.
    @Attribute(.externalStorage) public var thumbnailPNG: Data?
    
    /// Имя файла с raw-точками в GRDB-хранилище.
    public var trackFileReference: String
    
    @Relationship public var bike: Bike?
}
```

### Другие модели

- **Bike** -- `@Model`, велосипед пользователя.
- **Achievement** -- `@Model`, ачивки.
- **UserStats** -- `@Model`, агрегаты: totalDistance, totalRides, totalHexCount, eddingtonNumber, maxSquareSide, maxClusterSize. Обновляется FogCalculator после каждой поездки.

### Правила моделей

- В модели -- только **состояние**: поля, relationships, уникальные индексы.
- Не в модели -- логика сохранения, миграции, computed aggregations. Всё это в FogRidePersistence и FogRideServices.
- Computed properties -- осторожно. `trip.elevationGainFeet` (pure) -- ок. `trip.thumbnail: UIImage` -- **не ок**, UIKit в Domain запрещён.

---

## Domain/FogRidePersistence

Инкапсулирует конкретные технологии хранения (SwiftData + GRDB) за repository-like интерфейсами.

### TripRepository

```swift
public protocol TripRepository: Sendable {
    func save(_ trip: Trip, points: [RawLocation]) async throws
    func load(id: UUID) async throws -> Trip
    func loadPoints(for tripID: UUID) async throws -> [RawLocation]
    func list(sortedBy: TripSortOrder, limit: Int) async throws -> [Trip]
    func delete(id: UUID) async throws
    
    /// Observation -- поток изменений для SwiftUI.
    func observeList() -> AsyncStream<[Trip]>
}

public final class DefaultTripRepository: TripRepository {
    private let swiftDataContainer: ModelContainer
    private let pointsDatabase: DatabaseWriter  // GRDB
    
    // Сохраняет метаданные в SwiftData, raw-точки -- в GRDB. Транзакционно.
}
```

**Почему protocol:** тесты. `TripRecorder` в тестах получает mock-репозиторий без реальной SwiftData/GRDB.

### HexSnapshotRepository

```swift
public protocol HexSnapshotRepository: Sendable {
    func loadLatest() async throws -> CompactedHexSnapshot?
    func save(_ snapshot: CompactedHexSnapshot) async throws
}
```

### Swift 6 gotcha

`ModelContext` не `Sendable`. Repository работает внутри ограниченного актора и возвращает только value-types / `@Model`-классы, которые уже detached от контекста (через `.id` и повторный fetch).

### Стратегия хранения

| Данные | Хранилище | Причина |
|---|---|---|
| Метаданные поездок (Trip, Bike) | SwiftData + CloudKit | Синхронизация между устройствами |
| Raw GPS-точки (10k+ на поездку) | GRDB | Слишком тяжело для CloudKit |
| Hex-снапшоты | GRDB | Большие blob-ы, не синхронизируются |
| Achievements, UserStats | SwiftData + CloudKit | Синхронизация |

Подробнее о hex-схеме: [[HexKit#Persistence-схема для GRDB]]

---

## Domain/FogRideServices

«Сердце приложения» -- доменные сервисы, которые оркестрируют пакеты. Единственное место, где встречаются `LocationRecorder` + `HexCellSet` + `MetricsAccumulator` и превращаются в живой процесс записи поездки.

### TripRecorder

```swift
@Observable
@MainActor
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
    private let hexCellSet: HexCellSet
    private let repository: TripRepository
}
```

**Ключевые моменты:**

1. **TripRecorder -- единственный, кто соединяет пакеты.** Views не видят `LocationRecorder` напрямую. Новая фича расширяет `TripRecorder`, а не лезет в `LocationRecording`.
2. **`@MainActor`** потому что его state напрямую биндится в UI.
3. Использует [[LocationKit|LocationRecording]] для GPS-стрима, [[LocationKit|LocationFiltering]] для `AccuracyGate`, [[LocationKit|LocationAnalysis]] для метрик, [[HexKit|HexGeometry]] для hex-вставки.

### Обработка GPS-точки

```swift
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
```

### FogCalculator

```swift
public actor FogCalculator {
    public init(repository: HexSnapshotRepository, statsRepository: UserStatsRepository)
    
    /// Пересчитать всё с нуля. Вызывается в BGProcessingTask раз в сутки.
    public func recomputeAll() async throws
    
    /// Инкрементальное обновление после поездки -- дешевле полного пересчёта.
    public func updateAfterTrip(_ trip: Trip, newCells: Set<HexCell>) async throws
}
```

Вычисляет и обновляет агрегаты UserStats: Eddington, Max Square, Max Cluster.

### AchievementEngine

```swift
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

**События вместо прямых вызовов.** `AchievementEngine` слушает `DomainEvent`, а не вызывается руками из `TripRecorder`. Можно добавлять новых подписчиков (аналитика) без изменения recorder'а.

**Акторы для всего stateful.** `FogCalculator`, `AchievementEngine` -- акторы; `TripRecorder` -- `@MainActor`.

---

## Features -- анатомия feature-модуля

Структура типового пакета (на примере RecordingFeature):

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
│       │   └── MockTripRecorder.swift
│       └── Localization/
│           └── Localizable.xcstrings
└── Tests/
```

Feature НЕ тянет `LocationRecording` напрямую. Работает с `TripRecorder` из FogRideServices.

### View -> ViewModel -> Service

```swift
@Observable
@MainActor
public final class RecordingViewModel {
    private let tripRecorder: TripRecorder
    
    public var recordingState: TripRecorder.State { tripRecorder.state }
    public var metrics: LiveMetrics { tripRecorder.liveMetrics }
    public var newHexes: Int { tripRecorder.newHexesThisRide }
}
```

- View знает про `RecordingViewModel` и `FogMap`. Не знает про `LocationRecorder`, `HexCellSet`, GRDB.
- ViewModel -- обёртка над `TripRecorder`, экспонирующая state в удобном для SwiftUI виде.
- Environment (`mapStyle`) пробрасывается сверху из App-уровня.

---

## Composition root: AppServices

```swift
@main
struct FogRideApp: App {
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
}
```

### Порядок инициализации

1. Поднимаем persistence (SwiftData container + GRDB database + миграции).
2. Восстанавливаем состояние hex-сета из снапшота.
3. Создаём сервисы (TripRecorder, FogCalculator, AchievementEngine).

### Environment-паттерн

Feature-view получает нужный сервис из `Environment`:

```swift
struct RecordingScreen: View {
    @Environment(\.services) private var services
    
    var body: some View {
        RecordingView(viewModel: RecordingViewModel(tripRecorder: services.tripRecorder))
    }
}
```

Альтернатива -- DI-контейнер через Factory/Swinject. Для соло-разработчика избыточно; `Environment` работает и проще в тестах.

---

## Таблица-шпаргалка: где что живёт

| Сущность | Где живёт | Почему |
|---|---|---|
| `RawLocation` | [[LocationKit\|LocationRecording]] | Primitive, используемый многими пакетами |
| `HexCell`, `HexResolution` | [[HexKit\|HexCore]] | H3-примитив |
| `HexCellSet` | [[HexKit\|HexGeometry]] | Collection поверх H3 |
| `VisitedCells` protocol | [[MapVerse\|MapFogOfWar]] | Контракт для fog rendering |
| `MapCamera`, `MapBBox` | [[MapVerse\|MapCore]] | Map primitives |
| `Trip`, `Bike`, `Achievement` | FogRideModels | Domain entities |
| `TripRepository` protocol | FogRidePersistence | Domain contract |
| `DefaultTripRepository` impl | FogRidePersistence | SwiftData+GRDB реализация |
| `TripRecorder` | FogRideServices | Соединяет пакеты в доменный процесс |
| `FogCalculator` | FogRideServices | Доменная логика аналитики |
| `AchievementEngine` | FogRideServices | Доменная логика |
| `RecordingView`, VM | Features/RecordingFeature | UI-слой |
| `AppServices` | App/FogRideApp | Composition root |
| Цвета, шрифты | [[Прочие пакеты\|DesignSystem]] | Общие UI tokens |

См. также: [[Антипаттерны]], [[Обзор]]

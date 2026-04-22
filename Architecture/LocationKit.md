# LocationKit -- группа пакетов для GPS
> Четыре пакета: LocationRecording, LocationFiltering, LocationAnalysis, LocationMotion. Запись GPS, фильтрация шума, вычисление метрик, авто-пауза.

### Почему 4 пакета

- `LocationRecording` и `LocationFiltering` разделены, потому что фильтрация -- чистые функции без side-effects, которые тестируются без симулятора.
- `LocationAnalysis` вынесен, потому что работает и с лайв-стримом, и с сохранёнными треками (его используют и `TripRecorder`, и `TripDetailFeature`).
- `LocationMotion` -- отдельный, потому что `CoreMotion` имеет свои permissions и может не использоваться в будущих приложениях.

Используется в: [[Domain|TripRecorder]] для оркестрации записи поездки.

---

## LocationRecording

**Назначение:** async-native обёртка над `CLLocationUpdate.liveUpdates(.fitness)` с корректным управлением lifecycle. Phase 0 — foreground only; background session (CLBackgroundActivitySession) будет в Phase 1.

### Публичный API (реализовано в SCRUM-28)

```swift
public actor LocationRecorder {
    public init(configuration: RecordingConfiguration = .cycling)
    
    /// Основной вход. AsyncSequence локаций до cancellation. Идемпотентен.
    public func start() -> AsyncThrowingStream<RawLocation, any Error>
    
    public func pause()
    public func resume()
    public func stop()
    
    public private(set) var state: RecordingState { get }
}

public struct RawLocation: Sendable, Equatable {
    public let coordinate: CLLocationCoordinate2D
    public let altitude: CLLocationDistance
    public let horizontalAccuracy: CLLocationAccuracy
    public let verticalAccuracy: CLLocationAccuracy
    public let speed: CLLocationSpeed
    public let course: CLLocationDirection
    public let timestamp: Date
}

public struct RecordingConfiguration: Sendable, Equatable {
    public var activityType: CLActivityType  // default .fitness
    public var pausesAutomatically: Bool     // default false
    
    public static let cycling: Self
    public static let walking: Self
}

public enum LocationRecordingError: Error, Sendable, Equatable {
    case authorizationDenied
    case locationUnavailable
    case interrupted
}

public enum RecordingState: Sendable, Equatable {
    case idle, recording, paused, failed(LocationRecordingError)
}
```

**Отличия от первоначальной спеки:**
- `RecordingConfiguration`: `backgroundAllowed`/`showsBackgroundIndicator` убраны (Phase 0 foreground-only). Будут добавлены в Phase 1.
- `RecordingState.failed` использует типизированный `LocationRecordingError` вместо generic `Error` — для Swift 6 Sendable + Equatable compliance.
- Внутренний `LocationSource` протокол (package-internal) для тестирования без девайса.

### Ключевые обязанности

- Внутри -- `CLLocationUpdate.liveUpdates(.fitness)` через `LocationSource` протокол (production: `CLLocationUpdateSource`).
- `start()` идемпотентен: повторный вызов возвращает существующий stream.
- `LocationRecordingError.authorizationDenied / .locationUnavailable` пробрасываются в stream; приложение решает, как показать пользователю.
- `RawLocation` -- собственная структура (не `CLLocation`), потому что `CLLocation` не `Sendable` и содержит непрозрачное состояние.
- Пауза: flag-based (GPS session продолжает работать, yield пропускается). Быстрый resume.

### Что пакет НЕ делает

- Не фильтрует по accuracy -- это LocationFiltering.
- Не считает distance/speed агрегаты -- это LocationAnalysis.
- Не вставляет в `HKWorkoutRouteBuilder` -- это [[Прочие пакеты|WorkoutKit]] (крит. gotcha FB18603581).

### Зависимости

- CoreLocation

---

## LocationFiltering

**Назначение:** чистые функции и операторы AsyncSequence для очистки шумных GPS-данных.

### Публичный API

```swift
public struct AccuracyGate: Sendable {
    public var maxHorizontalAccuracy: Double = 30
    public var maxAge: TimeInterval = 5
    public var maxSpeed: Double = 25  // m/s, ~90 km/h для велосипеда
    
    public func passes(_ location: RawLocation) -> Bool
}

public final class KalmanFilter1D: Sendable {
    public init(processNoise: Double, measurementNoise: Double)
    public func update(_ location: RawLocation) -> RawLocation
    public func reset()
}

/// Douglas-Peucker для post-processing.
public enum LineSimplify {
    public static func simplify(
        _ points: [RawLocation],
        tolerance: Double  // метры
    ) -> [RawLocation]
}

// AsyncSequence extensions
extension AsyncSequence where Element == RawLocation {
    public func gated(by gate: AccuracyGate) -> AsyncFilterSequence<Self>
    public func kalman(_ filter: KalmanFilter1D) -> AsyncMapSequence<Self, RawLocation>
    public func deduplicated(minDistance: Double) -> ...
}
```

### Ключевые принципы

- Все фильтры -- value types или actors без UI-зависимостей.
- Kalman в realtime -- опционально, по умолчанию выключен; показываем raw для честности (это дифференциатор из роудмапа).
- Douglas-Peucker работает как функция над массивом, не над стримом.
- Никакой CoreLocation-специфики в самом Kalman -- принимает `RawLocation`, что делает его тестируемым с синтетическими данными.

### Зависимости

- CoreLocation (только для типов)

---

## LocationAnalysis

**Назначение:** вычисление метрик над лайв-стримом или сохранённым треком -- distance, elevation gain, speed stats, splits.

### Публичный API

```swift
public struct LiveMetrics: Sendable {
    public var distance: Double        // м
    public var duration: TimeInterval
    public var currentSpeed: Double    // m/s
    public var averageSpeed: Double
    public var maxSpeed: Double
    public var elevationGain: Double   // м
    public var elevationLoss: Double
    public var currentAltitude: Double?
}

public actor MetricsAccumulator {
    public init(altimeter: AltimeterSource = .gps)
    public func ingest(_ location: RawLocation) async
    public func ingest(altitude: AltitudeSample) async  // из CMAltimeter
    public var snapshot: LiveMetrics { get async }
    public func reset() async
}

public enum AltimeterSource: Sendable {
    case gps              // альтитуда из CLLocation
    case barometer        // CMAltimeter
    case fused            // предпочитаем барометр, fallback на GPS
}

/// Post-processing анализ завершённого трека.
public enum TrackAnalyzer {
    public static func analyze(
        points: [RawLocation],
        altitudes: [AltitudeSample]?
    ) -> TrackAnalysis
    
    public static func splits(
        points: [RawLocation],
        every distance: Double
    ) -> [Split]
}

public struct TrackAnalysis: Sendable {
    public let totalDistance: Double
    public let totalDuration: TimeInterval
    public let movingDuration: TimeInterval  // исключая stops
    public let elevationGain: Double
    public let elevationLoss: Double
    public let averageSpeed: Double
    public let averageMovingSpeed: Double
    public let maxSpeed: Double
    public let boundingBox: MapBBox
}
```

### Ключевые обязанности

- `MetricsAccumulator` -- actor для thread-safety при одновременных ingest из GPS и барометра.
- Elevation gain -- алгоритм Strava: суммируем положительные дельты барометрической высоты с порогом 0.3 м (чтобы не накапливать шум).
- Moving duration -- считаем время, когда `speed > 0.5 m/s` (фильтр светофоров).

### Что НЕ входит

- Вычисление открытых гексов -- это [[HexKit|HexGeometry]].
- HealthKit интеграция -- это [[Прочие пакеты|WorkoutKit]].

### Зависимости

- CoreLocation, CoreMotion

---

## LocationMotion

**Назначение:** `CMMotionActivityManager` обёртка, которая даёт async-стрим активностей и готовые сигналы для auto-pause.

### Публичный API

```swift
public actor MotionActivityMonitor {
    public func start() -> AsyncStream<MotionActivity>
    public func autoPauseSignals(
        for activityType: ExpectedActivity = .cycling,
        stationaryThreshold: TimeInterval = 10
    ) -> AsyncStream<AutoPauseSignal>
    public func stop()
}

public struct MotionActivity: Sendable {
    public let timestamp: Date
    public let stationary: Bool
    public let walking: Bool
    public let running: Bool
    public let cycling: Bool
    public let automotive: Bool
    public let confidence: ActivityConfidence
}

public enum AutoPauseSignal: Sendable {
    case shouldPause
    case shouldResume
}
```

### Зависимости

- CoreMotion

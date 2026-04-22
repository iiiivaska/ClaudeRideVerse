# PersistenceCore — GRDB infrastructure

> Тонкая обёртка над GRDB 7 для raw GPS-точек и тяжёлых данных, не синхронизируемых через CloudKit. Phase F (✅ scaffolded, SCRUM-20).

## Назначение

Хранение **горячих** данных, которые **нельзя** синхронизировать через CloudKit:

- Raw GPS-точки поездки (10k+ на трек)
- Compacted hex-снапшоты (для быстрого рендера fog без перерасчёта из треков)
- Миграции схемы

Метаданные (`Trip`, `Bike`, `Achievement`, `UserStats`) живут в **SwiftData + CloudKit** — см. [[Domain#Domain/FogRidePersistence]].

## Стек

- **GRDB 7.10+** (SPM, см. `Packages/PersistenceCore/Package.swift`)
- **WAL mode** — concurrent reads во время записи GPS-потока
- **Миграции** — явная версионируемая схема, см. `Migration.swift`
- **Async observation** — `AsyncValueObservation` хелперы поверх GRDB `ValueObservation`

## Публичный API

```swift
public struct DatabaseProvider: Sendable {
    /// Production-путь: WAL-файл в Application Support.
    public static func `default`() throws -> DatabaseProvider

    /// In-memory factory для unit-тестов.
    public static func inMemory() -> DatabaseProvider

    public func dbQueue() throws -> DatabaseQueue
}

public enum Migration {
    public static func registerAll(in migrator: inout DatabaseMigrator)
}
```

## Файлы

| Файл | Назначение |
|------|-----------|
| `PersistenceCore.swift` | Точка входа + конфигурация |
| `DatabaseProvider.swift` | `DatabaseQueue` factory (default + inMemory) |
| `Migration.swift` | `DatabaseMigrator` с версионированной схемой |
| `Observation+Async.swift` | `AsyncSequence`-bridge поверх GRDB observations |

## Использование

Domain-слой (`FogRidePersistence`) оборачивает `DatabaseProvider` в repository-интерфейсы:

```swift
// В Phase 1 / SCRUM-33:
public protocol TrackPointRepository: Sendable {
    func append(_ point: RawLocation, tripID: UUID) async throws
    func points(for tripID: UUID) -> AsyncSequence<RawLocation>
    func delete(tripID: UUID) async throws
}
```

## Правила

- **Никогда** не импортировать GRDB в Features/App напрямую — только через Domain-репозитории.
- Schema migrations — **только добавление** колонок/индексов. Destructive migrations делаются через отдельный `dataMigrator` с backup.
- In-memory provider — для каждого unit-теста отдельный, чтобы тесты были независимы.

## Связанные

- [[Domain]] — репозитории и сервисы, использующие PersistenceCore
- [[Обзор#Стратегия хранения]] — split SwiftData+CloudKit vs GRDB
- Phase 1 задача [[Roadmap/Phase 1 — MVP|SCRUM-33]] — Domain models + persistence

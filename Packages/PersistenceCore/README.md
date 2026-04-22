# PersistenceCore

GRDB infrastructure package for RideVerse. Provides WAL-configured database access, migration support, and async observation helpers.

## Quick Start

```swift
import PersistenceCore

// Define migrations
enum CreatePointsTable: Migration {
    static let identifier = "createPoints"
    static func migrate(_ db: Database) throws {
        try db.create(table: "trackPoint") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("tripID", .text).notNull().indexed()
            t.column("latitude", .double).notNull()
            t.column("longitude", .double).notNull()
            t.column("timestamp", .datetime).notNull()
        }
    }
}

// Open database
let dbURL = appSupportDir.appendingPathComponent("tracks.sqlite")
let provider = try DatabaseProvider(at: dbURL, migrations: [
    CreatePointsTable.self,
])
```

## WAL Mode

All file-based databases open in WAL (Write-Ahead Logging) mode with `synchronous = NORMAL`. This means:

- **Concurrent reads during writes** — readers never block writers and vice versa
- **Fast writes** — NORMAL sync is safe with WAL, avoids fsync on every commit
- **Journal size capped** at 4 MB to prevent unbounded WAL growth

In-memory databases (`DatabaseProvider.inMemory()`) use `DatabaseQueue` without WAL.

## Batch Inserts

For high-volume data (GPS points, hex snapshots), always use `writeInTransaction`:

```swift
try await provider.writeInTransaction { db in
    for point in gpsPoints {
        try point.insert(db)
    }
}
```

This wraps all inserts in a single transaction — critical for performance with 10k+ rows.

## VACUUM

After bulk deletions (e.g., track simplification with Douglas-Peucker), reclaim disk space:

```swift
try await provider.vacuum()
```

Avoid calling during active recording. A good time is after trip post-processing.

## Observation

Observe database changes as an `AsyncSequence`:

```swift
for try await count in provider.observe({ db in
    try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM trackPoint") ?? 0
}) {
    updateUI(pointCount: count)
}
```

## Testing

Use `DatabaseProvider.inMemory()` for unit tests and SwiftUI previews:

```swift
let provider = try DatabaseProvider.inMemory(migrations: [
    CreatePointsTable.self,
])
```

## Not in This Package

- Domain models (`Trip`, `Bike`, `Achievement`) — see `FogRidePersistence`
- SwiftData / CloudKit sync — handled at the domain layer
- Concrete table schemas — defined by consumers

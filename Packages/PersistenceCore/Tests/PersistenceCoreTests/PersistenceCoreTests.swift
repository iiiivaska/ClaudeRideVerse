import Testing
import Foundation
import GRDB
@testable import PersistenceCore

// MARK: - Test Migrations

enum CreateItemsTable: Migration {
    static let identifier = "createItems"
    static func migrate(_ db: Database) throws {
        try db.create(table: "item") { t in
            t.autoIncrementedPrimaryKey("id")
            t.column("name", .text).notNull()
            t.column("value", .double).notNull()
        }
    }
}

enum AddTimestampColumn: Migration {
    static let identifier = "addTimestamp"
    static func migrate(_ db: Database) throws {
        try db.alter(table: "item") { t in
            t.add(column: "createdAt", .datetime)
        }
    }
}

// MARK: - Temp DB Helper

private func makeTempDBURL() -> URL {
    FileManager.default.temporaryDirectory
        .appendingPathComponent("PersistenceCoreTests-\(UUID().uuidString)")
        .appendingPathExtension("sqlite")
}

private func removeTempDB(at url: URL) {
    let fm = FileManager.default
    for ext in ["", "-wal", "-shm"] {
        try? fm.removeItem(atPath: url.path + ext)
    }
}

// MARK: - Tests

@Suite("DatabaseProvider")
struct DatabaseProviderTests {

    @Test("File-based DB uses WAL journal mode")
    func walMode() async throws {
        let url = makeTempDBURL()
        defer { removeTempDB(at: url) }

        let provider = try DatabaseProvider(at: url)
        let mode = try await provider.writer.read { db in
            try String.fetchOne(db, sql: "PRAGMA journal_mode")
        }
        #expect(mode == "wal")
    }

    @Test("File-based DB uses synchronous NORMAL")
    func synchronousNormal() async throws {
        let url = makeTempDBURL()
        defer { removeTempDB(at: url) }

        let provider = try DatabaseProvider(at: url)
        let sync = try await provider.writer.read { db in
            try Int.fetchOne(db, sql: "PRAGMA synchronous")
        }
        // 1 = NORMAL
        #expect(sync == 1)
    }

    @Test("Migrations create tables")
    func migrationsApplied() async throws {
        let provider = try DatabaseProvider.inMemory(migrations: [
            CreateItemsTable.self,
        ])
        let tables = try await provider.writer.read { db in
            try String.fetchAll(db, sql: """
                SELECT name FROM sqlite_master WHERE type='table' AND name='item'
                """)
        }
        #expect(tables == ["item"])
    }

    @Test("Migrations run in order")
    func migrationOrdering() async throws {
        let provider = try DatabaseProvider.inMemory(migrations: [
            CreateItemsTable.self,
            AddTimestampColumn.self,
        ])
        let columns = try await provider.writer.read { db in
            try Row.fetchAll(db, sql: "PRAGMA table_info(item)").map {
                $0["name"] as String
            }
        }
        #expect(columns.contains("createdAt"))
    }

    @Test("Opening twice with same migrations is idempotent")
    func migrationIdempotency() async throws {
        let url = makeTempDBURL()
        defer { removeTempDB(at: url) }

        let migrations: [any Migration.Type] = [CreateItemsTable.self]
        _ = try DatabaseProvider(at: url, migrations: migrations)
        let provider2 = try DatabaseProvider(at: url, migrations: migrations)
        let count = try await provider2.writer.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM item")
        }
        #expect(count == 0)
    }

    @Test("In-memory factory creates working database")
    func inMemoryFactory() async throws {
        let provider = try DatabaseProvider.inMemory(migrations: [
            CreateItemsTable.self,
        ])
        try await provider.writer.write { db in
            try db.execute(sql: "INSERT INTO item (name, value) VALUES ('test', 42.0)")
        }
        let count = try await provider.writer.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM item")
        }
        #expect(count == 1)
    }

    @Test("Vacuum runs without error")
    func vacuumSucceeds() async throws {
        let url = makeTempDBURL()
        defer { removeTempDB(at: url) }

        let provider = try DatabaseProvider(at: url, migrations: [
            CreateItemsTable.self,
        ])
        try await provider.writer.write { db in
            for i in 0..<100 {
                try db.execute(sql: "INSERT INTO item (name, value) VALUES (?, ?)",
                               arguments: ["item\(i)", Double(i)])
            }
            try db.execute(sql: "DELETE FROM item")
        }
        try await provider.vacuum()
    }

    @Test("Batch write in transaction inserts all rows")
    func batchWrite() async throws {
        let provider = try DatabaseProvider.inMemory(migrations: [
            CreateItemsTable.self,
        ])
        try await provider.writeInTransaction { db in
            for i in 0..<1000 {
                try db.execute(sql: "INSERT INTO item (name, value) VALUES (?, ?)",
                               arguments: ["point\(i)", Double(i)])
            }
        }
        let count = try await provider.writer.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM item")
        }
        #expect(count == 1000)
    }

    @Test("Concurrent reads succeed during write (WAL)")
    func concurrentReadsDuringWrite() async throws {
        let url = makeTempDBURL()
        defer { removeTempDB(at: url) }

        let provider = try DatabaseProvider(at: url, migrations: [
            CreateItemsTable.self,
        ])

        // Seed some data
        try await provider.writer.write { db in
            for i in 0..<10 {
                try db.execute(sql: "INSERT INTO item (name, value) VALUES (?, ?)",
                               arguments: ["seed\(i)", Double(i)])
            }
        }

        // Start a write and concurrent read
        async let writeResult: Void = provider.writeInTransaction { db in
            for i in 10..<110 {
                try db.execute(sql: "INSERT INTO item (name, value) VALUES (?, ?)",
                               arguments: ["batch\(i)", Double(i)])
            }
        }

        // Read should succeed concurrently (WAL benefit)
        let count = try await provider.writer.read { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM item")
        }
        #expect(count != nil)

        try await writeResult
    }

    @Test("Observe emits updated values")
    func observation() async throws {
        let provider = try DatabaseProvider.inMemory(migrations: [
            CreateItemsTable.self,
        ])

        let observation = provider.observe { db in
            try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM item") ?? 0
        }

        var iterator = observation.makeAsyncIterator()

        // First emission: initial value
        let initial = try await iterator.next()
        #expect(initial == 0)

        // Insert a row
        try await provider.writer.write { db in
            try db.execute(sql: "INSERT INTO item (name, value) VALUES ('a', 1.0)")
        }

        // Next emission should reflect the insert
        let afterInsert = try await iterator.next()
        #expect(afterInsert == 1)
    }
}

@Suite("Migration protocol")
struct MigrationProtocolTests {

    @Test("buildMigrator registers all migrations")
    func migratorRegistersAll() throws {
        let migrations: [any Migration.Type] = [
            CreateItemsTable.self,
            AddTimestampColumn.self,
        ]
        let migrator = buildMigrator(from: migrations)
        let queue = try DatabaseQueue()
        try migrator.migrate(queue)

        let columns = try queue.read { db in
            try Row.fetchAll(db, sql: "PRAGMA table_info(item)").map {
                $0["name"] as String
            }
        }
        #expect(columns.contains("id"))
        #expect(columns.contains("name"))
        #expect(columns.contains("createdAt"))
    }
}

@Suite("PersistenceCore module")
struct ModuleTests {

    @Test("Version is set")
    func versionIsSet() {
        #expect(PersistenceCore.version == "1.0.0")
    }

    @Test("GRDB types are accessible via re-export")
    func grdbReExport() throws {
        // DatabaseQueue is from GRDB — accessible without separate import
        let queue = try DatabaseQueue()
        try queue.read { db in
            let result = try Int.fetchOne(db, sql: "SELECT 1")
            #expect(result == 1)
        }
    }
}

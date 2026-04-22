import Foundation
import GRDB

/// Manages a GRDB database connection with WAL mode, migrations, and maintenance.
///
/// `DatabaseProvider` is the entry point for all database operations in the app.
/// It configures SQLite for optimal performance (WAL + synchronous NORMAL) and
/// runs migrations on first open.
///
/// For tests and SwiftUI previews, use ``inMemory(migrations:)``.
public final class DatabaseProvider: Sendable {

    /// The underlying database writer (reads and writes).
    public let writer: any DatabaseWriter

    /// Creates a file-based database with WAL mode enabled.
    ///
    /// - Parameters:
    ///   - url: File URL for the SQLite database.
    ///   - migrations: Ordered array of migration types to apply.
    /// - Throws: If the database cannot be opened or migrations fail.
    public init(at url: URL, migrations: [any Migration.Type] = []) throws {
        var config = Configuration()
        config.prepareDatabase { db in
            // WAL mode enables concurrent reads during writes
            try db.execute(sql: "PRAGMA journal_mode = WAL")
            // NORMAL synchronous is safe with WAL and much faster than FULL
            try db.execute(sql: "PRAGMA synchronous = NORMAL")
            // Cap WAL file size at 4 MB to prevent unbounded growth
            try db.execute(sql: "PRAGMA journal_size_limit = 4194304")
        }

        let pool = try DatabasePool(path: url.path, configuration: config)
        self.writer = pool

        let migrator = buildMigrator(from: migrations)
        try migrator.migrate(pool)
    }

    /// Creates an in-memory database for tests and previews.
    ///
    /// Uses `DatabaseQueue` (single connection) — no WAL mode, no concurrent reads.
    /// Suitable for unit tests and SwiftUI previews only.
    ///
    /// - Parameter migrations: Ordered array of migration types to apply.
    /// - Returns: A configured ``DatabaseProvider``.
    public static func inMemory(migrations: [any Migration.Type] = []) throws -> DatabaseProvider {
        let queue = try DatabaseQueue()
        let migrator = buildMigrator(from: migrations)
        try migrator.migrate(queue)
        return DatabaseProvider(writer: queue)
    }

    /// Reclaims unused disk space.
    ///
    /// Call periodically after bulk deletions (e.g., after Douglas-Peucker track
    /// simplification). Avoid calling during active recording.
    public func vacuum() async throws {
        try await writer.writeWithoutTransaction { db in
            try db.execute(sql: "VACUUM")
        }
    }

    // MARK: - Private

    private init(writer: any DatabaseWriter) {
        self.writer = writer
    }
}

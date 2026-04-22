import GRDB

/// A stateless schema migration step.
///
/// Conform an enum to this protocol to define a migration:
/// ```swift
/// enum CreateTrackPointsTable: Migration {
///     static let identifier = "createTrackPoints"
///     static func migrate(_ db: Database) throws {
///         try db.create(table: "trackPoint") { t in
///             t.primaryKey("id", .integer)
///             t.column("latitude", .double).notNull()
///         }
///     }
/// }
/// ```
public protocol Migration: Sendable {
    /// Unique identifier for this migration. Must be stable across app versions.
    static var identifier: String { get }

    /// Apply the migration to the database.
    static func migrate(_ db: Database) throws
}

/// Builds a GRDB `DatabaseMigrator` from an array of ``Migration`` types.
func buildMigrator(from migrations: [any Migration.Type]) -> DatabaseMigrator {
    var migrator = DatabaseMigrator()
    for migration in migrations {
        migrator.registerMigration(migration.identifier) { db in
            try migration.migrate(db)
        }
    }
    return migrator
}

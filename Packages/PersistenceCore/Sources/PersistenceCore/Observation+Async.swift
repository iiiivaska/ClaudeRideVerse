import GRDB

extension DatabaseProvider {

    /// Observes database changes and emits values as an `AsyncSequence`.
    ///
    /// ```swift
    /// for try await count in provider.observe({ db in
    ///     try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM trackPoint")
    /// }) {
    ///     print("Row count: \(count ?? 0)")
    /// }
    /// ```
    ///
    /// - Parameter fetch: A closure that reads from the database. Called on every
    ///   relevant transaction commit.
    /// - Returns: An `AsyncSequence` of fetched values.
    public func observe<T: Sendable>(
        _ fetch: @Sendable @escaping (Database) throws -> T
    ) -> AsyncValueObservation<T> {
        ValueObservation
            .tracking(fetch)
            .values(in: writer)
    }

    /// Executes a write block inside a single transaction.
    ///
    /// `writer.write` already wraps the closure in a transaction, so all
    /// inserts/updates/deletes are atomic. Use this for batch operations:
    /// ```swift
    /// try await provider.writeInTransaction { db in
    ///     for point in gpsPoints {
    ///         try point.insert(db)
    ///     }
    /// }
    /// ```
    @discardableResult
    public func writeInTransaction<T: Sendable>(
        _ updates: @Sendable @escaping (Database) throws -> T
    ) async throws -> T {
        try await writer.write { db in
            try updates(db)
        }
    }
}

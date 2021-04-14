#if compiler(>=5.4) && $AsyncAwait
import _Concurrency
import MongoSwift
import NIO
import _NIOConcurrency

extension ClientSession {
    /// Ends this `ClientSession`. Call this method when you are finished using the session. You must ensure that all
    /// operations using this session have completed before calling this. The returned future must be fulfilled before
    /// this session's parent `MongoClient` is closed.
    public func end() async throws {
        try await self.end().get()
    }

    /**
     * Starts a multi-document transaction for all subsequent operations in this session.
     *
     * Any options provided in `options` will override the default transaction options for this session and any options
     * inherited from `MongoClient`.
     *
     * Operations executed as part of the transaction will use the options specified on the transaction, and those
     * options cannot be overridden at a per-operation level. Any options that overlap with the transaction options
     * which can be specified at a per operation level (e.g. write concern) _will be ignored_ if specified. This
     * includes options specified at the database or collection level on the object used to execute an operation.
     *
     * The transaction must be completed with `commitTransaction` or `abortTransaction`. An in-progress transaction is
     * automatically aborted when `ClientSession.end()` is called.
     *
     * - Parameters:
     *   - options: The options to use when starting this transaction
     *
     * - Throws:
     *   - `MongoError.CommandError` if an error occurs that prevents the command from executing.
     *   - `MongoError.LogicError` if the session already has an in-progress transaction.
     *   - `MongoError.LogicError` if `startTransaction` is called on an ended session.
     *
     * - SeeAlso:
     *   - https://docs.mongodb.com/manual/core/transactions/
     */
    public func startTransaction(options: TransactionOptions? = nil) async throws {
        try await self.startTransaction(options: options).get()
    }

    /**
     * Commits a multi-document transaction for this session. Server and network errors are not ignored.
     *
     * - Throws:
     *   - `MongoError.CommandError` if an error occurs that prevents the command from executing.
     *   - `MongoError.LogicError` if the session has no in-progress transaction.
     *   - `MongoError.LogicError` if `commitTransaction` is called on an ended session.
     *
     * - SeeAlso:
     *   - https://docs.mongodb.com/manual/core/transactions/
     */
    public func commitTransaction() async throws {
        try await self.commitTransaction().get()
    }

    /**
     * Aborts a multi-document transaction for this session. Server and network errors are ignored.
     *
     * - Throws:
     *   - `MongoError.LogicError` if the session has no in-progress transaction.
     *   - `MongoError.LogicError` if `abortTransaction` is called on an ended session.
     *
     * - SeeAlso:
     *   - https://docs.mongodb.com/manual/core/transactions/
     */
    public func abortTransaction() async throws {
        try await self.abortTransaction().get()
    }
}

#endif

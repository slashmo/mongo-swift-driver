#if compiler(>=5.4) && $AsyncAwait
import _Concurrency
import MongoSwift
import NIO
import _NIOConcurrency

extension MongoCursor: AsyncSequence, AsyncIteratorProtocol {
    public typealias AsyncIterator = MongoCursor

    public typealias Element = T

    public __consuming func makeAsyncIterator() -> MongoCursor<T> {
        self
    }

    public func next() async throws -> T? {
        try await self.next().get()
    }

    /**
     * Attempt to get the next `T` from the cursor, returning `nil` if there are no results.
     *
     * If this cursor is tailable, this method may be called repeatedly while `isAlive` is true to retrieve new data.
     *
     * If this cursor is a tailable await cursor, it will wait for results server side for a maximum of `maxAwaitTimeMS`
     * before returning `nil`. This option can be configured via options passed to the method that created this
     * cursor (e.g. the `maxAwaitTimeMS` option on the `FindOptions` passed to `find`).
     *
     * - Returns:
     *   A `Result<T, Error>?` containing the next `T` in this cursor on success, an error if one occurred, or `nil`
     *   if there were no results.
     *
     *   On failure, there error returned is likely one of the following:
     *     - `MongoError.CommandError` if an error occurs while fetching more results from the server.
     *     - `MongoError.LogicError` if this function is called after the cursor has died.
     *     - `MongoError.LogicError` if this function is called and the session associated with this cursor is inactive.
     *     - `DecodingError` if an error occurs decoding the server's response.
     */
    public func tryNext() async throws -> T? {
        try await self.tryNext().get()
    }

    public func kill() async throws {
        try await self.kill().get()
    }
}

#endif

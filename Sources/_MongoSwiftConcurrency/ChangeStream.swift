#if compiler(>=5.4) && $AsyncAwait
import _Concurrency
import MongoSwift
import NIO
import _NIOConcurrency

extension ChangeStream: AsyncSequence, AsyncIteratorProtocol {
    public typealias AsyncIterator = ChangeStream

    public typealias Element = T

    public __consuming func makeAsyncIterator() -> ChangeStream<T> {
        self
    }

    public func next() async throws -> T? {
        try await self.next().get()
    }

    /**
     * Attempt to get the next `T` from this change stream, returning `nil` if there are no results.
     *
     * The change stream will wait server-side for a maximum of `maxAwaitTimeMS` (specified on the
     * `ChangeStreamOptions` passed to the method that created this change stream) before returning `nil`.
     *
     * This method may be called repeatedly while `isAlive` is true to retrieve new data.
     *
     * - Returns:
     *    A `Result<T, Error>?` containing the next `T` in this change stream, an error if one occurred, or `nil` if
     *    there was no data.
     *
     *    If the result is an error, it is likely one of the following:
     *      - `MongoError.CommandError` if an error occurs while fetching more results from the server.
     *      - `MongoError.LogicError` if this function is called after the change stream has died.
     *     - `MongoError.LogicError` if this function is called and the session associated with this change stream is
     *       inactive.
     *      - `DecodingError` if an error occurs decoding the server's response.
     */
    public func tryNext() async throws -> T? {
        try await self.tryNext().get()
    }

    public func kill() async throws {
        try await self.kill().get()
    }
}

#endif

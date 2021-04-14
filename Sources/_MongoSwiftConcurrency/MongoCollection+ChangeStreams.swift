#if compiler(>=5.4) && $AsyncAwait
import _Concurrency
import MongoSwift
import NIO
import _NIOConcurrency

extension MongoCollection {
    /**
     * Starts a `ChangeStream` on a collection. The `CollectionType` will be associated with the `fullDocument`
     * field in `ChangeStreamEvent`s emitted by the returned `ChangeStream`. The server will return an error if
     * this method is called on a system collection.
     *
     * - Parameters:
     *   - pipeline: An array of aggregation pipeline stages to apply to the events returned by the change stream.
     *   - options: An optional `ChangeStreamOptions` to use when constructing the change stream.
     *   - session: An optional `ClientSession` to use with this change stream.
     *
     * - Returns: A `ChangeStream` on a specific collection.
     *
     * - Throws:
     *   - `MongoError.CommandError` if an error occurs on the server while creating the change stream.
     *   - `MongoError.InvalidArgumentError` if the options passed formed an invalid combination.
     *   - `MongoError.InvalidArgumentError` if the `_id` field is projected out of the change stream documents by the
     *     pipeline.
     *
     * - SeeAlso:
     *   - https://docs.mongodb.com/manual/changeStreams/
     *   - https://docs.mongodb.com/manual/meta/aggregation-quick-reference/
     *   - https://docs.mongodb.com/manual/reference/system-collections/
     */
    public func watch(
        _ pipeline: [BSONDocument] = [],
        options: ChangeStreamOptions? = nil,
        session: ClientSession? = nil
    ) async throws -> ChangeStream<ChangeStreamEvent<CollectionType>> {
        try await self.watch(
            pipeline,
            options: options,
            session: session,
            withEventType: ChangeStreamEvent<CollectionType>.self
        )
    }

    /**
     * Starts a `ChangeStream` on a collection. Associates the specified `Codable` type `T` with the `fullDocument`
     * field in the `ChangeStreamEvent`s emitted by the returned `ChangeStream`. The server will return an error
     * if this method is called on a system collection.
     *
     * - Parameters:
     *   - pipeline: An array of aggregation pipeline stages to apply to the events returned by the change stream.
     *   - options: An optional `ChangeStreamOptions` to use when constructing the change stream.
     *   - session: An optional `ClientSession` to use with this change stream.
     *   - withFullDocumentType: The type that the `fullDocument` field of the emitted `ChangeStreamEvent`s will be
     *                           decoded to.
     *
     * - Returns: A `ChangeStream` on a specific collection.
     *
     * - Throws:
     *   - `MongoError.CommandError` if an error occurs on the server while creating the change stream.
     *   - `MongoError.InvalidArgumentError` if the options passed formed an invalid combination.
     *   - `MongoError.InvalidArgumentError` if the `_id` field is projected out of the change stream documents by the
     *     pipeline.
     *
     * - SeeAlso:
     *   - https://docs.mongodb.com/manual/changeStreams/
     *   - https://docs.mongodb.com/manual/meta/aggregation-quick-reference/
     *   - https://docs.mongodb.com/manual/reference/system-collections/
     */
    public func watch<FullDocType: Codable>(
        _ pipeline: [BSONDocument] = [],
        options: ChangeStreamOptions? = nil,
        session: ClientSession? = nil,
        withFullDocumentType _: FullDocType.Type
    ) async throws -> ChangeStream<ChangeStreamEvent<FullDocType>> {
        try await self.watch(
            pipeline,
            options: options,
            session: session,
            withEventType: ChangeStreamEvent<FullDocType>.self
        )
    }

    /**
     * Starts a `ChangeStream` on a collection. Associates the specified `Codable` type `T` with the returned
     * `ChangeStream`. The server will return an error if this method is called on a system collection.
     *
     * - Parameters:
     *   - pipeline: An array of aggregation pipeline stages to apply to the events returned by the change stream.
     *   - options: An optional `ChangeStreamOptions` to use when constructing the change stream.
     *   - session: An optional `ClientSession` to use with this change stream.
     *   - withEventType: The type that the entire change stream response will be decoded to and that will be returned
     *                    when iterating through the change stream.
     *
     * - Returns: A `ChangeStream` on a specific collection.
     *
     * - Throws:
     *   - `MongoError.CommandError` if an error occurs on the server while creating the change stream.
     *   - `MongoError.InvalidArgumentError` if the options passed formed an invalid combination.
     *   - `MongoError.InvalidArgumentError` if the `_id` field is projected out of the change stream documents by the
     *     pipeline.
     *
     * - SeeAlso:
     *   - https://docs.mongodb.com/manual/changeStreams/
     *   - https://docs.mongodb.com/manual/meta/aggregation-quick-reference/
     *   - https://docs.mongodb.com/manual/reference/system-collections/
     */
    public func watch<EventType: Codable>(
        _ pipeline: [BSONDocument] = [],
        options: ChangeStreamOptions? = nil,
        session: ClientSession? = nil,
        withEventType _: EventType.Type
    ) async throws -> ChangeStream<EventType> {
        try await self.watch(pipeline, options: options, session: session, withEventType: EventType.self).get()
    }
}

#endif

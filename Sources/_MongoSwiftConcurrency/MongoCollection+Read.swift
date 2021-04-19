#if compiler(>=5.4) && $AsyncAwait
import _Concurrency
import CLibMongoC
import MongoSwift
import NIO
import _NIOConcurrency
import Tracing
import TracingOpenTelemetrySupport

@available(macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, *)
extension MongoCollection {
    /**
     * Finds the documents in this collection which match the provided filter.
     *
     * - Parameters:
     *   - filter: A `Document` that should match the query
     *   - options: Optional `FindOptions` to use when executing the command
     *   - session: Optional `ClientSession` to use when executing this command
     *
     * - Returns: A `MongoCursor` over the resulting `Document`s
     *
     * - Throws:
     *   - `MongoError.InvalidArgumentError` if the options passed are an invalid combination.
     *   - `MongoError.LogicError` if the provided session is inactive.
     *   - `EncodingError` if an error occurs while encoding the options to BSON.
     */
    public func find(
        _ filter: BSONDocument = [:],
        options: FindOptions? = nil,
        session: ClientSession? = nil
    ) async throws -> MongoCursor<CollectionType> {
        try await InstrumentationSystem.tracer.withSpan("\(name).find") { span in
            span.attributes.db.system = "mongodb"
            span.attributes.db.operation = "find"
            span.attributes.db.mongodb.collection = name
            span.attributes.db.name = namespace.db
            // TODO: Use actual values
            span.attributes.db.user = session?.client._connectionString.username
            span.attributes.net.peer.port = (session?.client._connectionString.hosts?.first?.port).map(Int.init)
            span.attributes.net.peer.ip = (session?.client._connectionString.hosts?.first?.host)
            span.attributes.net.transport = "IP.TCP"
            do {
                let cursor = try await self.find(filter, options: options, session: session).get()
                return cursor
            } catch {
                span.recordError(error)
                span.setStatus(SpanStatus(code: .error, message: "\(error)"))
                throw error
            }
        }
    }

    /**
     * Finds a single document in this collection that matches the provided filter.
     *
     * - Parameters:
     *   - filter: A `Document` that should match the query
     *   - options: Optional `FindOneOptions` to use when executing the command
     *   - session: Optional `ClientSession` to use when executing this command
     *
     * - Returns:  the resulting `Document`, or nil if there is no match
     *
     * - Throws:
     *   - `MongoError.InvalidArgumentError` if the options passed are an invalid combination.
     *   - `MongoError.LogicError` if the provided session is inactive.
     *   - `EncodingError` if an error occurs while encoding the options to BSON.
     */
    public func findOne(
        _ filter: BSONDocument = [:],
        options: FindOneOptions? = nil,
        session: ClientSession? = nil
    ) async throws -> T? {
        try await InstrumentationSystem.tracer.withSpan("\(name).findOne") { span in
            span.attributes.db.system = "mongodb"
            span.attributes.db.operation = "findOne"
            span.attributes.db.mongodb.collection = name
            span.attributes.db.name = namespace.db
            // TODO: Use actual values
            span.attributes.db.user = session?.client._connectionString.username
            span.attributes.net.peer.port = (session?.client._connectionString.hosts?.first?.port).map(Int.init)
            span.attributes.net.peer.ip = (session?.client._connectionString.hosts?.first?.host)
            span.attributes.net.transport = "IP.TCP"
            do {
                return try await self.findOne(filter, options: options, session: session).get()
            } catch {
                span.recordError(error)
                span.setStatus(SpanStatus(code: .error, message: "\(error)"))
                throw error
            }
        }
    }

    /**
     * Runs an aggregation framework pipeline against this collection.
     *
     * - Parameters:
     *   - pipeline: an `[BSONDocument]` containing the pipeline of aggregation operations to perform
     *   - options: Optional `AggregateOptions` to use when executing the command
     *   - session: Optional `ClientSession` to use when executing this command
     *
     * - Returns: A `MongoCursor` over the resulting `Document`s
     *
     * - Throws:
     *   - `MongoError.InvalidArgumentError` if the options passed are an invalid combination.
     *   - `MongoError.LogicError` if the provided session is inactive.
     *   - `EncodingError` if an error occurs while encoding the options to BSON.
     */
    public func aggregate(
        _ pipeline: [BSONDocument],
        options: AggregateOptions? = nil,
        session: ClientSession? = nil
    ) async throws -> MongoCursor<BSONDocument> {
        try await self.aggregate(pipeline, options: options, session: session, withOutputType: BSONDocument.self)
    }

    /**
     * Runs an aggregation framework pipeline against this collection.
     * Associates the specified `Codable` type `OutputType` with the returned `MongoCursor`
     *
     * - Parameters:
     *   - pipeline: an `[BSONDocument]` containing the pipeline of aggregation operations to perform
     *   - options: Optional `AggregateOptions` to use when executing the command
     *   - session: Optional `ClientSession` to use when executing this command
     *   - withOutputType: the type that each resulting document of the output
     *     of the aggregation operation will be decoded to
     * - Returns: A `MongoCursor` over the resulting `OutputType`s
     *
     * - Throws:
     *   - `MongoError.InvalidArgumentError` if the options passed are an invalid combination.
     *   - `MongoError.LogicError` if the provided session is inactive.
     *   - `EncodingError` if an error occurs while encoding the options to BSON.
     */
    public func aggregate<OutputType: Codable>(
        _ pipeline: [BSONDocument],
        options: AggregateOptions? = nil,
        session: ClientSession? = nil,
        withOutputType _: OutputType.Type
    ) async throws -> MongoCursor<OutputType> {
        try await self.aggregate(
            pipeline,
            options: options,
            session: session,
            withOutputType: OutputType.self
        ).get()
    }

    /**
     * Counts the number of documents in this collection matching the provided filter. Note that an empty filter will
     * force a scan of the entire collection. For a fast count of the total documents in a collection see
     * `estimatedDocumentCount`.
     *
     * - Parameters:
     *   - filter: a `Document`, the filter that documents must match in order to be counted
     *   - options: Optional `CountDocumentsOptions` to use when executing the command
     *   - session: Optional `ClientSession` to use when executing this command
     *
     * - Returns: The count of the documents that matched the filter
     */
    public func countDocuments(
        _ filter: BSONDocument = [:],
        options: CountDocumentsOptions? = nil,
        session: ClientSession? = nil
    ) async throws -> Int {
        try await self.countDocuments(filter, options: options, session: session).get()
    }

    /**
     * Gets an estimate of the count of documents in this collection using collection metadata. This operation cannot
     * be used in a transaction.
     *
     * - Parameters:
     *   - options: Optional `EstimatedDocumentCountOptions` to use when executing the command
     *
     * - Returns: an estimate of the count of documents in this collection
     */
    public func estimatedDocumentCount(options: EstimatedDocumentCountOptions? = nil) async throws -> Int {
        try await self.estimatedDocumentCount(options: options).get()
    }

    /**
     * Finds the distinct values for a specified field across the collection.
     *
     * - Parameters:
     *   - fieldName: The field for which the distinct values will be found
     *   - filter: a `Document` representing the filter documents must match in order to be considered for the operation
     *   - options: Optional `DistinctOptions` to use when executing the command
     *   - session: Optional `ClientSession` to use when executing this command
     *
     * - Returns: A `[BSONValue]` containing the distinct values for the specified criteria
     *
     * - Throws:
     *   - `MongoError.CommandError` if an error occurs that prevents the command from executing.
     *   - `MongoError.InvalidArgumentError` if the options passed in form an invalid combination.
     *   - `MongoError.LogicError` if the provided session is inactive.
     *   - `EncodingError` if an error occurs while encoding the options to BSON.
     */
    public func distinct(
        fieldName: String,
        filter: BSONDocument = [:],
        options: DistinctOptions? = nil,
        session: ClientSession? = nil
    ) async throws -> [BSON] {
        try await self.distinct(fieldName: fieldName, filter: filter, options: options, session: session).get()
    }
}

@available(macOS 9999, iOS 9999, watchOS 9999, tvOS 9999, *)
extension MongoCursor {
    public func toArray() async throws -> [T] {
        try await self.toArray().get()
    }
}

#endif

import CLibMongoC

/// Options to use when executing a `countDocuments` command on a `MongoCollection`.
public struct CountDocumentsOptions: Codable {
    /// Specifies a collation.
    public var collation: BSONDocument?

    /// A hint for the index to use.
    public var hint: IndexHint?

    /// The maximum number of documents to count.
    public var limit: Int?

    /// The maximum amount of time to allow the query to run.
    public var maxTimeMS: Int?

    /// A ReadConcern to use for this operation.
    public var readConcern: ReadConcern?

    // swiftlint:disable redundant_optional_initialization
    /// A ReadPreference to use for this operation.
    public var readPreference: ReadPreference? = nil
    // swiftlint:enable redundant_optional_initialization

    /// The number of documents to skip before counting.
    public var skip: Int?

    /// Convenience initializer allowing any/all parameters to be optional
    public init(
        collation: BSONDocument? = nil,
        hint: IndexHint? = nil,
        limit: Int? = nil,
        maxTimeMS: Int? = nil,
        readConcern: ReadConcern? = nil,
        readPreference: ReadPreference? = nil,
        skip: Int? = nil
    ) {
        self.collation = collation
        self.hint = hint
        self.limit = limit
        self.maxTimeMS = maxTimeMS
        self.readConcern = readConcern
        self.readPreference = readPreference
        self.skip = skip
    }

    private enum CodingKeys: String, CodingKey {
        case collation, hint, limit, maxTimeMS, readConcern, skip
    }

    func toAggregateOptions(collectionReadConcern: ReadConcern?) -> AggregateOptions {
        AggregateOptions(
            collation: self.collation,
            hint: self.hint,
            maxTimeMS: self.maxTimeMS,
            readConcern: self.readConcern ?? collectionReadConcern
        )
    }
}

internal struct CountDocumentsResponse: Codable {
    let n: Int
}

/// An operation corresponding to a "count" command on a collection.
internal struct CountDocumentsOperation<T: Codable>: Operation {
    private let collection: MongoCollection<T>
    private let filter: BSONDocument
    private let options: CountDocumentsOptions?

    internal init(collection: MongoCollection<T>, filter: BSONDocument, options: CountDocumentsOptions?) {
        self.collection = collection
        self.filter = filter
        self.options = options
    }

    internal func execute(using connection: Connection, session: ClientSession?) throws -> MongoCursor<CountDocumentsResponse> {
        let readPref = options?.readPreference ?? collection.readPreference

        let server = try connection.selectServer(forWrites: false, readPreference: readPref)
        let aggregateOpts = (options ?? CountDocumentsOptions()).toAggregateOptions(collectionReadConcern: collection.readConcern)

        let opts = try encodeOptions(options: aggregateOpts, server: server, session: session)

        var pipeline = [BSONDocument]()
        pipeline.append(["$match": .document(self.filter)])
        if let skip = options?.skip {
            pipeline.append(["$skip": .int64(Int64(skip))])
        }
        if let limit = options?.limit {
            pipeline.append(["$limit": .int64(Int64(limit))])
        }
        pipeline.append(["$group": ["_id": 1, "n": ["$sum": 1]]])

        let cmd: BSONDocument = [
            "aggregate": .string(collection.name),
            "cursor": [:],
            "pipeline": .array(pipeline.map { .document($0) })
        ]

        let cursorPtr = try connection.withMongocConnection { connPtr in
            try readPref.withMongocReadPreference { rpPtr in
                try runMongocCursorCommand(connPtr: connPtr, command: cmd, options: opts) { cmdPtr, optsPtr, replyPtr, error in
                    mongoc_client_read_command_with_opts(connPtr, collection.namespace.db, cmdPtr, rpPtr, optsPtr, replyPtr, &error)
                }
            }
        }

        return try MongoCursor(
            stealing: cursorPtr,
            connection: connection,
            client: collection._client,
            decoder: collection.decoder,
            eventLoop: collection.eventLoop,
            session: session
        )
    }
}

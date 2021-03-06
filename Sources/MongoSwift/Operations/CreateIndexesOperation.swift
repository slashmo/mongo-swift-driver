import CLibMongoC

/// Options to use when creating a new index on a `MongoCollection`.
public struct CreateIndexOptions: Encodable {
    /// The maximum amount of time to allow the query to run - enforced server-side.
    public var maxTimeMS: Int?

    /// An optional `WriteConcern` to use for the command.
    public var writeConcern: WriteConcern?

    /// Initializer allowing any/all parameters to be omitted.
    public init(maxTimeMS: Int? = nil, writeConcern: WriteConcern? = nil) {
        self.maxTimeMS = maxTimeMS
        self.writeConcern = writeConcern
    }
}

/// An operation corresponding to a "createIndexes" command.
internal struct CreateIndexesOperation<T: Codable>: Operation {
    private let collection: MongoCollection<T>
    private let models: [IndexModel]
    private let options: CreateIndexOptions?

    internal init(collection: MongoCollection<T>, models: [IndexModel], options: CreateIndexOptions?) {
        self.collection = collection
        self.models = models
        self.options = options
    }

    internal func execute(using connection: Connection, session: ClientSession?) throws -> [String] {
        var indexData = [BSON]()
        var indexNames = [String]()
        for index in self.models {
            var indexDoc = try self.collection.encoder.encode(index)

            if let indexName = index.options?.name {
                indexNames.append(indexName)
            } else {
                let indexName = try index.getDefaultName()
                indexDoc["name"] = .string(indexName)
                indexNames.append(indexName)
            }

            indexData.append(.document(indexDoc))
        }

        let command: BSONDocument = ["createIndexes": .string(self.collection.name), "indexes": .array(indexData)]

        let server = try connection.selectServer(forWrites: true, readPreference: nil)

        // todo: switching to the client methods means we lose db/collection RC and WC application so this is
        // just a hacky way to deal with that here.
        // we could still use the coll/db runCommand methods, as they accept serverIds, but seems preferable to
        // just go ahead and start handling that logic on our side via some abstractions, and just always use the 
        // client command methods a la PHP.
        var optsWithWC = self.options ?? CreateIndexOptions()
        if optsWithWC.writeConcern == nil {
            optsWithWC.writeConcern = self.collection.writeConcern
        }

        let opts = try encodeOptions(options: optsWithWC, server: server, session: session)

        try connection.withMongocConnection { connPtr in
            try runMongocCommand(command: command, options: opts) { cmdPtr, optsPtr, replyPtr, error in
                mongoc_client_write_command_with_opts(connPtr, self.collection.namespace.db, cmdPtr, optsPtr, replyPtr, &error)
            }
        }

        return indexNames
    }
}

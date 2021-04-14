#if compiler(>=5.4) && $AsyncAwait
import _Concurrency
import Dispatch
import MongoSwift
import _MongoSwiftConcurrency
import NIO

let elg = MultiThreadedEventLoopGroup(numberOfThreads: 1)
defer {
    try? elg.syncShutdownGracefully()
}

func main() async throws {
    let client = try MongoClient(using: elg)
    let coll = client.db("asyncTestDB").collection("test")

    let result = try await coll.insertMany([["x": 1], ["x": 2], ["x": 3]])
    print("Inserted IDs: \(result!.insertedIDs)")

    for try await doc in try await coll.find() {
        print("found document: \(doc)")
    }

    try await coll.drop()
    try await client.close()
}

let dg = DispatchGroup()
dg.enter()
let task = Task.runDetached {
    do {
        try await main()
        print("success!")
    } catch {
        print("failed! \(error)")
    }
    dg.leave()
}
dg.wait()

#endif

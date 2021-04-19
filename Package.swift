// swift-tools-version:5.1
import PackageDescription
let package = Package(
    name: "mongo-swift-driver",
    platforms: [
        .macOS(.v10_14)
    ],
    products: [
        .library(name: "MongoSwift", targets: ["MongoSwift"]),
        .library(name: "MongoSwiftSync", targets: ["MongoSwiftSync"]),
        .library(name: "_MongoSwiftConcurrency", targets: ["_MongoSwiftConcurrency"])
    ],
    dependencies: [
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/apple/swift-nio", .revision("f6936ae8132e14c64ed971764065e6842358fde0")),
        .package(url: "https://github.com/mongodb/swift-bson", .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", .branch("async")),
    ],
    targets: [
        .target(
            name: "MongoSwift",
            dependencies: [
                "CLibMongoC", "NIO", "NIOConcurrencyHelpers", "SwiftBSON", "Tracing", "TracingOpenTelemetrySupport"
            ]
        ),
        .target(name: "MongoSwiftSync", dependencies: ["MongoSwift", "NIO"]),
        .target(
            name: "_MongoSwiftConcurrency",
            dependencies: ["MongoSwift", "_NIOConcurrency"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"]),
            ]
        ),
        .target(
            name: "MongoSwiftAsyncAwaitDemo",
            dependencies: ["_MongoSwiftConcurrency", "NIO"],
            swiftSettings: [
                .unsafeFlags(["-Xfrontend", "-enable-experimental-concurrency"]),
            ]
        ),
        .target(name: "AtlasConnectivity", dependencies: ["MongoSwiftSync"]),
        .target(name: "TestsCommon", dependencies: ["MongoSwift", "Nimble"]),
        .testTarget(name: "BSONTests", dependencies: ["MongoSwift", "TestsCommon", "Nimble", "CLibMongoC"]),
        .testTarget(name: "MongoSwiftTests", dependencies: ["MongoSwift", "TestsCommon", "Nimble", "NIO"]),
        .testTarget(name: "MongoSwiftSyncTests", dependencies: ["MongoSwiftSync", "TestsCommon", "Nimble", "MongoSwift"]),
        .target(
            name: "CLibMongoC",
            dependencies: [],
            linkerSettings: [
                .linkedLibrary("resolv"),
                .linkedLibrary("ssl", .when(platforms: [.linux])),
                .linkedLibrary("crypto", .when(platforms: [.linux])),
                .linkedLibrary("z", .when(platforms: [.linux]))
            ]
        )
    ]
)

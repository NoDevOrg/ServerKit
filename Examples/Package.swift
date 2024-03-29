// swift-tools-version: 5.7
import PackageDescription

let package = Package(name: "Examples")

package.platforms = [
    .macOS(.v13),
]

package.dependencies = [
    .package(name: "ServerKit", path: "../"),

    // Need to explicitly add packages that are included with ServerKit to use plugins
    .package(url: "https://github.com/apple/swift-protobuf", from: "1.0.0"),
    .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
]

package.targets = [
    .executableTarget(name: "ExampleDualServer", dependencies: [
        .product(name: "ServerKit", package: "ServerKit"),
    ], resources: [
        .copy("IDL"),
        .copy("swift-protobuf-config.json"),
        .copy("grpc-swift-config.json"),
    ], plugins: [
        .plugin(name: "SwiftProtobufPlugin", package: "SwiftProtobuf"),
        .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift"),
    ]),
    .executableTarget(name: "ExampleGRPCServer", dependencies: [
        .product(name: "ServerKit", package: "ServerKit"),
    ], resources: [
        .copy("IDL"),
        .copy("swift-protobuf-config.json"),
        .copy("grpc-swift-config.json"),
    ], plugins: [
        .plugin(name: "SwiftProtobufPlugin", package: "SwiftProtobuf"),
        .plugin(name: "GRPCSwiftPlugin", package: "grpc-swift"),
    ]),
    .executableTarget(name: "ExampleGraphQLServer", dependencies: [
        .product(name: "ServerKit", package: "ServerKit"),
    ]),
    .executableTarget(name: "ExampleGraphQLSubgraphServer", dependencies: [
        .product(name: "ServerKit", package: "ServerKit"),
    ], resources: [
        .copy("IDL"),
    ])
]

package.products = [
    .executable(name: "ExampleDualServer", targets: ["ExampleDualServer"]),
    .executable(name: "ExampleGRPCServer", targets: ["ExampleGRPCServer"]),
    .executable(name: "ExampleGraphQLServer", targets: ["ExampleGraphQLServer"]),
]

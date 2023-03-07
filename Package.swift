// swift-tools-version: 5.7
import PackageDescription

let package = Package(name: "ServerKit")

package.platforms = [
    .macOS(.v13),
]

package.dependencies = [
    .package(url: "https://github.com/GraphQLSwift/Graphiti", from: "1.0.0"),
    .package(url: "https://github.com/grpc/grpc-swift", from: "1.0.0"),
    .package(url: "https://github.com/vapor/vapor", from: "4.0.0"),
]

package.targets = [
    .target(name: "ServerKit", dependencies: [
        .product(name: "Graphiti", package: "Graphiti"),
        .product(name: "GRPC", package: "grpc-swift"),
        .product(name: "Vapor", package: "vapor"),
    ]),
]

package.products = [
    .library(name: "ServerKit", targets: ["ServerKit"]),
]

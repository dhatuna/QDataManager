// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QDataManager",
    platforms: [
        .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "QDataManager",
            targets: ["QDataManager"]),
        .library(
            name: "QJSONDataManager",
            targets: ["QJSONDataManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.0")
    ],
    targets: [
        .target(
            name: "QUtils",
            dependencies: [],
            path: "Sources/Utils"
        ),
        .target(
            name: "QDataManager",
            dependencies: [
                "AnyCodable",
                "QUtils"
            ],
            path: "Sources/QDataManager"
        ),
        .target(
            name: "QJSONDataManager",
            dependencies: [
                "AnyCodable",
                "QUtils"
            ],
            path: "Sources/QJSONDataManager"
        ),
        .testTarget(
            name: "QDataManagerTests",
            dependencies: [
                "QDataManager",
                "QJSONDataManager",
                "QUtils"
            ],
            path: "Tests/QDataManagerTests"
        ),
    ]
)

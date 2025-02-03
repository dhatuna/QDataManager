// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "QDataManager",
    platforms: [
        .iOS(.v13), .macOS(.v10_15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "QDataManager",
            targets: ["QDataManager"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "QDataManager",
            dependencies: [],
            path: "Sources/QDataManager",
            exclude: ["README.md"]
        ),
        .testTarget(
            name: "QDataManagerTests",
            dependencies: ["QDataManager"],
            path: "Tests/QDataManagerTests"
        ),
    ]
)

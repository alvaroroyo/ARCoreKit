// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ARCoreKit",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ARCoreKit",
            targets: ["ARCoreKit"]),
        //APIRequest
        .library(
            name: "APIRequest",
            targets: ["APIRequest"]),
        //ARControls
        .library(
            name: "ARControls",
            targets: ["ARControls"]),
        //ARSnapshotTests
        .library(
            name: "ARSnapshotTests",
            targets: ["ARSnapshotTests"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", from: "1.15.3"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ARCoreKit"),
        .testTarget(
            name: "ARCoreKitTests",
            dependencies: ["ARCoreKit"]),
        //APIRequest
        .target(
            name: "APIRequest",
            path: "Sources/APIRequest"),
        .testTarget(
            name: "APIRequest-Tests",
            dependencies: ["APIRequest"],
            path: "Tests/APIRequest"),
        //ARControls
        .target(
            name: "ARControls",
            path: "Sources/ARControls"),
        .testTarget(
            name: "ARControlsTests",
            dependencies: ["ARControls"],
            path: "Tests/ARControls"),
        //ARSnapshotTests
        .target(
            name: "ARSnapshotTests",
            dependencies: [
                .product(name: "SnapshotTesting", package: "swift-snapshot-testing")
            ],
            path: "Sources/ARSnapshotTests"),
    ]
)

// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YoloTrainingData",
    dependencies: [
        .package(url: "https://github.com/tomieq/Logger", from: "1.1.0"),
        .package(url: "https://github.com/tomieq/SwiftExtensions", from: "2.0.0"),
        .package(url: "https://github.com/tomieq/Env", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "YoloTrainingData",
            dependencies: [
                .product(name: "Logger", package: "Logger"),
                .product(name: "SwiftExtensions", package: "SwiftExtensions"),
                .product(name: "Env", package: "Env")
            ]
        ),
    ]
)

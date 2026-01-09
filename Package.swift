// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "YoloTrainingData",
    dependencies: [
        .package(url: "https://github.com/tomieq/BootstrapStarter", branch: "master"),
        .package(url: "https://github.com/tomieq/swifter", from: "3.0.0"),
        .package(url: "https://github.com/tomieq/Template.swift.git", from: "1.6.0"),
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
                .product(name: "BootstrapTemplate", package: "BootstrapStarter"),
                .product(name: "Swifter", package: "Swifter"),
                .product(name: "Template", package: "Template.swift"),
                .product(name: "Logger", package: "Logger"),
                .product(name: "SwiftExtensions", package: "SwiftExtensions"),
                .product(name: "Env", package: "Env")
            ]
        ),
    ]
)

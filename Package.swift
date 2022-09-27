// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MaintainabilityIndexCalculator",
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", exact: "0.50600.1"),
    ],
    targets: [
        .executableTarget(
            name: "MaintainabilityIndexCalculator",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ]),
        .testTarget(
            name: "MaintainabilityIndexCalculatorTests",
            dependencies: [
                "MaintainabilityIndexCalculator",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxParser", package: "swift-syntax"),
            ]),
    ]
)

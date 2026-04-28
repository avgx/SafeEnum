// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SafeEnum",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macCatalyst(.v15),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SafeEnum",
            targets: ["SafeEnum"]
        ),
    ],
    targets: [
        .target(
            name: "SafeEnum"
        ),
        .testTarget(
            name: "SafeEnumTests",
            dependencies: ["SafeEnum"]
        ),
    ]
)

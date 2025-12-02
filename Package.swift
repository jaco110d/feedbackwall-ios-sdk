// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.
// Using 5.7 for broader Xcode compatibility (Xcode 14+)

import PackageDescription

let package = Package(
    name: "FeedbackWall",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FeedbackWall",
            targets: ["FeedbackWall"]
        ),
    ],
    targets: [
        .target(
            name: "FeedbackWall",
            dependencies: [],
            path: "Sources/FeedbackWall"
        ),
        .testTarget(
            name: "FeedbackWallTests",
            dependencies: ["FeedbackWall"],
            path: "Tests/FeedbackWallTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)


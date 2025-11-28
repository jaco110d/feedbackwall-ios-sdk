// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
    ]
)


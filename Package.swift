// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "cruxx",
    targets: [
        .target(
            name: "cruxx",
            dependencies: [],
            path: "Sources/CRUXX"
        ),
        .testTarget(
            name: "cruxxTests",
            dependencies: ["cruxx"],
            path: "Tests/CRUXXTests"
        )
    ]
)

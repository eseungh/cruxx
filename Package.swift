// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "cruxx",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(name: "cruxxApp", targets: ["cruxxApp"]),
        .library(name: "cruxxCore", targets: ["cruxxCore"]),
        .library(name: "cruxxModel", targets: ["cruxxModel"])
    ],
    targets: [
        .target(
            name: "cruxxApp",
            dependencies: ["cruxxCore", "cruxxModel"],
            path: "Sources/cruxxApp"
        ),
        .target(
            name: "cruxxCore",
            dependencies: ["cruxxModel"],
            path: "Sources/cruxxCore"
        ),
        .target(
            name: "cruxxModel",
            path: "Sources/cruxxModel"
        ),
        .testTarget(
            name: "cruxxCoreTests",
            dependencies: ["cruxxCore"],
            path: "Tests/cruxxCoreTests"
        )
    ]
)

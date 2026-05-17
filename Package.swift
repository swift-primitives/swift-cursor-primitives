// swift-tools-version: 6.3.1

import PackageDescription

let package = Package(
    name: "swift-cursor-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Cursor Primitives Core",
            targets: ["Cursor Primitives Core"]
        ),
        .library(
            name: "Cursor Span Primitives",
            targets: ["Cursor Span Primitives"]
        ),
        .library(
            name: "Cursor Primitives",
            targets: ["Cursor Primitives"]
        ),
        .library(
            name: "Cursor Primitives Test Support",
            targets: ["Cursor Primitives Test Support"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-tagged-primitives"),
        .package(path: "../swift-ordinal-primitives"),
        .package(path: "../swift-cardinal-primitives"),
        .package(path: "../swift-index-primitives"),
    ],
    targets: [
        // MARK: - Core

        .target(
            name: "Cursor Primitives Core",
            dependencies: [
                .product(name: "Tagged Primitives", package: "swift-tagged-primitives"),
                .product(name: "Ordinal Primitives", package: "swift-ordinal-primitives"),
                .product(name: "Cardinal Primitives", package: "swift-cardinal-primitives"),
            ]
        ),

        // MARK: - Variants

        .target(
            name: "Cursor Span Primitives",
            dependencies: [
                "Cursor Primitives Core",
            ]
        ),

        // MARK: - Umbrella

        .target(
            name: "Cursor Primitives",
            dependencies: [
                "Cursor Primitives Core",
                "Cursor Span Primitives",
            ]
        ),

        // MARK: - Test Support

        .target(
            name: "Cursor Primitives Test Support",
            dependencies: [
                "Cursor Primitives",
                .product(name: "Index Primitives Test Support", package: "swift-index-primitives"),
            ],
            path: "Tests/Support"
        ),

        // MARK: - Tests

        .testTarget(
            name: "Cursor Span Primitives Tests",
            dependencies: [
                "Cursor Span Primitives",
                "Cursor Primitives Test Support",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem
}

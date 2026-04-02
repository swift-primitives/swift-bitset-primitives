// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "swift-bitset-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26)
    ],
    products: [
        .library(
            name: "Bitset Primitives",
            targets: ["Bitset Primitives"]
        )
    ],
    dependencies: [
        .package(path: "../swift-sequence-primitives"),
    ],
    targets: [
        .target(
            name: "Bitset Primitives",
            dependencies: [
                .product(name: "Sequence Primitives", package: "swift-sequence-primitives"),
            ]
        ),
        .testTarget(
            name: "Bitset Primitives Tests",
            dependencies: [
                "Bitset Primitives",
            ]
        )
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
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}

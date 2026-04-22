// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HexKit",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "HexCore", targets: ["HexCore"]),
        .library(name: "HexGeometry", targets: ["HexGeometry"]),
    ],
    targets: [
        .target(
            name: "HexCore",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .target(
            name: "HexGeometry",
            dependencies: ["HexCore"],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .testTarget(
            name: "HexCoreTests",
            dependencies: ["HexCore"]
        ),
        .testTarget(
            name: "HexGeometryTests",
            dependencies: ["HexGeometry"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

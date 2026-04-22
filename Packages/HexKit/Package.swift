// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HexKit",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "HexCore", targets: ["HexCore"]),
        .library(name: "HexGeometry", targets: ["HexGeometry"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pawelmajcher/SwiftyH3.git", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "HexCore",
            dependencies: [
                .product(name: "SwiftyH3", package: "SwiftyH3"),
            ],
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

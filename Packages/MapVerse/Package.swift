// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "MapVerse",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "MapCore", targets: ["MapCore"]),
        .library(name: "MapFogOfWar", targets: ["MapFogOfWar"]),
    ],
    dependencies: [
        .package(path: "../HexKit"),
    ],
    targets: [
        .target(
            name: "MapCore",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .target(
            name: "MapFogOfWar",
            dependencies: [
                "MapCore",
                .product(name: "HexCore", package: "HexKit"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .testTarget(
            name: "MapCoreTests",
            dependencies: ["MapCore"]
        ),
        .testTarget(
            name: "MapFogOfWarTests",
            dependencies: ["MapFogOfWar"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

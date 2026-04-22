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
        .package(url: "https://github.com/maplibre/maplibre-gl-native-distribution.git", from: "6.23.0"),
        .package(url: "https://github.com/maplibre/swiftui-dsl.git", .upToNextMinor(from: "0.21.1")),
    ],
    targets: [
        .target(
            name: "MapCore",
            dependencies: [
                .product(name: "MapLibre", package: "maplibre-gl-native-distribution"),
            ],
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

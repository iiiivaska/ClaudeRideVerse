// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PersistenceCore",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "PersistenceCore", targets: ["PersistenceCore"]),
    ],
    targets: [
        .target(
            name: "PersistenceCore",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .testTarget(
            name: "PersistenceCoreTests",
            dependencies: ["PersistenceCore"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

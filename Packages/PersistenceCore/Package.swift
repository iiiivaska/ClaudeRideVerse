// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "PersistenceCore",
    platforms: [.iOS(.v26), .macOS(.v26)],
    products: [
        .library(name: "PersistenceCore", targets: ["PersistenceCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.10.0"),
    ],
    targets: [
        .target(
            name: "PersistenceCore",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .testTarget(
            name: "PersistenceCoreTests",
            dependencies: [
                "PersistenceCore",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

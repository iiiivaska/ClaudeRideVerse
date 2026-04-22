// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "DesignSystem",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "DesignSystem", targets: ["DesignSystem"]),
    ],
    targets: [
        .target(
            name: "DesignSystem",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .testTarget(
            name: "DesignSystemTests",
            dependencies: ["DesignSystem"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

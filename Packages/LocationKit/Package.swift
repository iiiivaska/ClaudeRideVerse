// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "LocationKit",
    platforms: [.iOS(.v26), .macOS(.v15)],
    products: [
        .library(name: "LocationRecording", targets: ["LocationRecording"]),
    ],
    targets: [
        .target(
            name: "LocationRecording",
            swiftSettings: [
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .enableUpcomingFeature("InferIsolatedConformances"),
            ]
        ),
        .testTarget(
            name: "LocationRecordingTests",
            dependencies: ["LocationRecording"]
        ),
    ],
    swiftLanguageModes: [.v6]
)

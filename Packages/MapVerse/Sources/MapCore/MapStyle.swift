import Foundation

/// Describes a map tile style, constructing the full URL with credentials.
public struct MapStyle: Sendable, Equatable {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    /// Stadia Outdoors style with the given API key.
    public static func stadiaOutdoors(apiKey: String) -> MapStyle {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "tiles.stadiamaps.com"
        components.path = "/styles/outdoors/style.json"
        components.queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
        // swiftlint:disable:next force_unwrapping
        return MapStyle(url: components.url!)
    }

    /// Loads Stadia Outdoors using `STADIA_API_KEY` from the process environment.
    ///
    /// Returns `nil` if the environment variable is not set.
    public static func stadiaOutdoorsFromEnvironment() -> MapStyle? {
        guard let key = ProcessInfo.processInfo.environment["STADIA_API_KEY"], !key.isEmpty else {
            return nil
        }
        return .stadiaOutdoors(apiKey: key)
    }

    /// MapLibre demo tiles — no API key required. Suitable for previews and CI.
    public static let demotiles = MapStyle(
        // swiftlint:disable:next force_unwrapping
        url: URL(string: "https://demotiles.maplibre.org/style.json")!
    )
}

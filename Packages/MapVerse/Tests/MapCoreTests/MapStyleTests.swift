import Testing
@testable import MapCore

@Suite("MapStyle")
struct MapStyleTests {

    @Test func stadiaOutdoorsContainsAPIKey() {
        let style = MapStyle.stadiaOutdoors(apiKey: "test-key-123")
        #expect(style.url.absoluteString.contains("api_key=test-key-123"))
        #expect(style.url.absoluteString.contains("outdoors"))
        #expect(style.url.absoluteString.contains("tiles.stadiamaps.com"))
    }

    @Test func stadiaOutdoorsURLStructure() {
        let style = MapStyle.stadiaOutdoors(apiKey: "k")
        #expect(style.url.scheme == "https")
        #expect(style.url.host == "tiles.stadiamaps.com")
        #expect(style.url.path.contains("style.json"))
    }

    @Test func demotilesURLIsValid() {
        let style = MapStyle.demotiles
        #expect(style.url.absoluteString == "https://demotiles.maplibre.org/style.json")
    }

    @Test func equalityOnSameURL() {
        let first = MapStyle.stadiaOutdoors(apiKey: "key")
        let second = MapStyle.stadiaOutdoors(apiKey: "key")
        #expect(first == second)
    }

    @Test func inequalityOnDifferentKeys() {
        let style1 = MapStyle.stadiaOutdoors(apiKey: "key1")
        let style2 = MapStyle.stadiaOutdoors(apiKey: "key2")
        #expect(style1 != style2)
    }
}

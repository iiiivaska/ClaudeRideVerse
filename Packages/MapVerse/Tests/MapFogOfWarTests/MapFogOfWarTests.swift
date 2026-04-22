import Testing
@testable import MapFogOfWar

@Test func scaffoldVersionMatchesCore() {
    #expect(MapFogOfWar.scaffoldVersion == "0.0.1")
}

@Test func hexRuntimeIsWiredIn() {
    #expect(MapFogOfWar.hexRuntime == "0.0.1")
}

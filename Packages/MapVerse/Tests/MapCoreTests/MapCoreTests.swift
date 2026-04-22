import Testing
@testable import MapCore

@Suite("MapCore Module")
struct MapCoreModuleTests {
    @Test func moduleImportsSuccessfully() {
        // Verify the module compiles and core types are accessible.
        let camera = MapCamera.amsterdam
        #expect(camera.zoom > 0)
    }
}

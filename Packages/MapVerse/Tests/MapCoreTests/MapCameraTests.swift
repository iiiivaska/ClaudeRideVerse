import CoreLocation
import Testing
@testable import MapCore

@Suite("MapCamera")
struct MapCameraTests {

    @Test func initWithDefaults() {
        let camera = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 10
        )
        #expect(camera.bearing == 0)
        #expect(camera.pitch == 0)
    }

    @Test func initWithAllParameters() {
        let camera = MapCamera(
            center: CLLocationCoordinate2D(latitude: 48.8, longitude: 2.3),
            zoom: 15,
            bearing: 90,
            pitch: 45
        )
        #expect(camera.center.latitude == 48.8)
        #expect(camera.center.longitude == 2.3)
        #expect(camera.zoom == 15)
        #expect(camera.bearing == 90)
        #expect(camera.pitch == 45)
    }

    @Test func equalityWithSameValues() {
        let lhs = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 13,
            bearing: 45,
            pitch: 30
        )
        let rhs = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 13,
            bearing: 45,
            pitch: 30
        )
        #expect(lhs == rhs)
    }

    @Test func inequalityOnCenter() {
        let original = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 13
        )
        let shifted = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.1, longitude: 4.0),
            zoom: 13
        )
        #expect(original != shifted)
    }

    @Test func inequalityOnZoom() {
        let zoomedOut = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 13
        )
        let zoomedIn = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 14
        )
        #expect(zoomedOut != zoomedIn)
    }

    @Test func inequalityOnBearing() {
        let north = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 13,
            bearing: 0
        )
        let south = MapCamera(
            center: CLLocationCoordinate2D(latitude: 52.0, longitude: 4.0),
            zoom: 13,
            bearing: 180
        )
        #expect(north != south)
    }

    @Test func amsterdamPreset() {
        let cam = MapCamera.amsterdam
        #expect(cam.center.latitude == 52.3676)
        #expect(cam.center.longitude == 4.9041)
        #expect(cam.zoom == 13)
        #expect(cam.bearing == 0)
        #expect(cam.pitch == 0)
    }

    @Test func sendableConformance() {
        let camera = MapCamera.amsterdam
        let _: any Sendable = camera
    }
}

#if canImport(UIKit)
import SwiftUI

#Preview("Amsterdam — Demo Tiles") {
    @Previewable @State var camera = MapCamera.amsterdam
    MapView(camera: $camera, style: .demotiles) {}
}

#Preview("Amsterdam — Stadia Outdoors") {
    @Previewable @State var camera = MapCamera.amsterdam
    let style = MapStyle.stadiaOutdoorsFromEnvironment() ?? .demotiles
    MapView(camera: $camera, style: style) {}
}
#endif

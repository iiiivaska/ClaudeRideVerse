#if canImport(UIKit)
import SwiftUI

/// A SwiftUI map view backed by MapLibre Native.
///
/// Wraps `MLNMapView` with a two-way ``MapCamera`` binding and
/// declarative ``MapContent`` composition.
///
/// ```swift
/// @State var camera = MapCamera.amsterdam
///
/// MapView(camera: $camera, style: .demotiles) { }
/// ```
public struct MapView<Content: MapContent>: View {
    @Binding private var camera: MapCamera
    private let style: MapStyle
    private let content: Content

    public init(
        camera: Binding<MapCamera>,
        style: MapStyle,
        @MapContentBuilder content: () -> Content
    ) {
        self._camera = camera
        self.style = style
        self.content = content()
    }

    public var body: some View {
        MapViewRepresentable(camera: $camera, style: style)
            .ignoresSafeArea()
    }
}
#endif

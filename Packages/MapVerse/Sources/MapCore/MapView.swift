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
///
/// - Warning: The declarative ``MapContent`` builder passed to `content`
///   is **accepted but not yet applied** to the underlying `MLNMapView`.
///   The overlay pipeline (style sources + layers for polylines, markers,
///   clusters, etc.) lands with the MapOverlays target — tracked in
///   SCRUM-92 (API wiring) and SCRUM-32 (MapOverlays package). Until then,
///   only the camera + base style render. Existing call sites pass empty
///   closures, so this is not a regression — but any non-empty `content`
///   is silently ignored today.
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
        // `content` is retained for forward-compatibility (SCRUM-92). When the
        // overlay pipeline lands it will be applied here via an
        // `applyContent(_:to:)` extension on `MapViewRepresentable`. Until then
        // we read it to keep the generic parameter alive without warnings.
        _ = content
        return MapViewRepresentable(camera: $camera, style: style)
            .ignoresSafeArea()
    }
}
#endif

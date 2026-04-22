/// A type that can contribute visual content to a ``MapView``.
///
/// Concrete conformances (polylines, markers, fog layers) are provided by
/// downstream packages such as MapOverlays and MapFogOfWar.
public protocol MapContent: Sendable {}

/// Empty map content — used when no overlays are needed.
public struct EmptyMapContent: MapContent {}

/// Combines two map content values into one.
public struct MapContentGroup<First: MapContent, Second: MapContent>: MapContent {
    public let first: First
    public let second: Second

    public init(first: First, second: Second) {
        self.first = first
        self.second = second
    }
}

/// Wraps an optional map content value.
public struct OptionalMapContent<Wrapped: MapContent>: MapContent {
    public let wrapped: Wrapped?

    public init(_ wrapped: Wrapped?) {
        self.wrapped = wrapped
    }
}

/// Type-erased container for conditional map content.
public struct ConditionalMapContent<TrueContent: MapContent, FalseContent: MapContent>: MapContent {
    enum Storage: Sendable {
        case first(TrueContent)
        case second(FalseContent)
    }

    let storage: Storage
}

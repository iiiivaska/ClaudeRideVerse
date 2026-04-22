/// Result builder for composing ``MapContent`` declaratively inside a ``MapView``.
@resultBuilder
public enum MapContentBuilder {
    public static func buildBlock() -> EmptyMapContent {
        EmptyMapContent()
    }

    public static func buildBlock<C: MapContent>(_ content: C) -> C {
        content
    }

    public static func buildBlock<First: MapContent, Second: MapContent>(
        _ first: First,
        _ second: Second
    ) -> MapContentGroup<First, Second> {
        MapContentGroup(first: first, second: second)
    }

    public static func buildBlock<First: MapContent, Second: MapContent, Third: MapContent>(
        _ first: First,
        _ second: Second,
        _ third: Third
    ) -> MapContentGroup<MapContentGroup<First, Second>, Third> {
        MapContentGroup(first: MapContentGroup(first: first, second: second), second: third)
    }

    public static func buildOptional<C: MapContent>(_ content: C?) -> OptionalMapContent<C> {
        OptionalMapContent(content)
    }

    public static func buildEither<T: MapContent, F: MapContent>(
        first content: T
    ) -> ConditionalMapContent<T, F> {
        ConditionalMapContent(storage: .first(content))
    }

    public static func buildEither<T: MapContent, F: MapContent>(
        second content: F
    ) -> ConditionalMapContent<T, F> {
        ConditionalMapContent(storage: .second(content))
    }
}

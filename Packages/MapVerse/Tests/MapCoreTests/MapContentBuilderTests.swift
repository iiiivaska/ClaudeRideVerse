import Testing
@testable import MapCore

/// Concrete test content for builder verification.
private struct TestContent: MapContent {
    let id: Int
}

@Suite("MapContentBuilder")
struct MapContentBuilderTests {

    @Test func emptyBuilderProducesEmptyContent() {
        @MapContentBuilder func build() -> some MapContent {
        }
        let content = build()
        #expect(content is EmptyMapContent)
    }

    @Test func singleContentPassesThrough() {
        @MapContentBuilder func build() -> some MapContent {
            TestContent(id: 1)
        }
        let content = build()
        #expect(content is TestContent)
    }

    @Test func twoContentProducesGroup() {
        @MapContentBuilder func build() -> some MapContent {
            TestContent(id: 1)
            TestContent(id: 2)
        }
        let content = build()
        #expect(content is MapContentGroup<TestContent, TestContent>)
    }

    @Test func threeContentProducesNestedGroup() {
        @MapContentBuilder func build() -> some MapContent {
            TestContent(id: 1)
            TestContent(id: 2)
            TestContent(id: 3)
        }
        let content = build()
        #expect(content is MapContentGroup<MapContentGroup<TestContent, TestContent>, TestContent>)
    }

    @Test func optionalContentWhenNil() {
        let showExtra = false
        @MapContentBuilder func build() -> some MapContent {
            if showExtra {
                TestContent(id: 1)
            }
        }
        let content = build()
        #expect(content is OptionalMapContent<TestContent>)
    }
}

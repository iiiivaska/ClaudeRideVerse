import Testing
@testable import PersistenceCore

@Test func scaffoldVersionIsSet() {
    #expect(PersistenceCore.scaffoldVersion == "0.0.1")
}

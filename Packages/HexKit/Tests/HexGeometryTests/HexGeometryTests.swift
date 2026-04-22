import Testing

@testable import HexGeometry

@Test func hexGeometryModuleImports() {
    // Verify module is importable and core types are accessible
    let set = HexCellSet()
    #expect(set.isEmpty)
}

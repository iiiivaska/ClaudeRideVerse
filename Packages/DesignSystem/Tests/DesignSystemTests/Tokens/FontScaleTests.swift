import SwiftUI
import Testing
@testable import DesignSystem

@MainActor
@Suite("Typography scale resolves via SF Pro / SF Mono")
struct FontScaleTests {

    @Test("All sans entries resolve without throwing")
    func sansScale() {
        _ = Font.fogTitleL
        _ = Font.fogHeading
        _ = Font.fogButton
        _ = Font.fogBody
        _ = Font.fogCaption
        _ = Font.fogMicro
    }

    @Test("All mono entries resolve without throwing")
    func monoScale() {
        _ = Font.fogMonoXL
        _ = Font.fogMonoLg
        _ = Font.fogMonoMd
        _ = Font.fogMonoSm
        _ = Font.fogMonoCap
    }
}

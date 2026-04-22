import SwiftUI
import Testing
@testable import DesignSystem

@Suite("Font registrar — idempotent + fallback-safe")
struct FontRegistrarTests {

    @Test("ensureRegistered runs exactly once per access, without crashing")
    func registrarIdempotent() {
        _ = FogRideFontRegistrar.ensureRegistered
        _ = FogRideFontRegistrar.ensureRegistered
        FogRideFontRegistrar.register()
        FogRideFontRegistrar.register()
    }

    @Test("Every font face in FogRideFont enum has a stable rawValue")
    func allFacesHaveRawValues() {
        for face in FogRideFont.allCases {
            #expect(!face.rawValue.isEmpty)
        }
    }

    @Test("Monospaced face classification is correct")
    func monospacedClassification() {
        #expect(FogRideFont.plexMonoRegular.isMonospaced)
        #expect(FogRideFont.plexMonoMedium.isMonospaced)
        #expect(FogRideFont.plexMonoSemiBold.isMonospaced)
        #expect(!FogRideFont.dmSansRegular.isMonospaced)
        #expect(!FogRideFont.dmSansBold.isMonospaced)
    }

    @Test("Font scale resolves without throwing")
    func fontScaleResolves() {
        _ = Font.fogTitleL
        _ = Font.fogHeading
        _ = Font.fogButton
        _ = Font.fogBody
        _ = Font.fogCaption
        _ = Font.fogMicro
        _ = Font.fogMonoXL
        _ = Font.fogMonoLg
        _ = Font.fogMonoMd
        _ = Font.fogMonoSm
        _ = Font.fogMonoCap
    }
}

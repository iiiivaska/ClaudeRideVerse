import SwiftUI
import CoreText

public extension Font {

    // MARK: - DM Sans (sans-serif)

    static var fogTitleL: Font { .fogCustom(.dmSansBold, size: 26, relativeTo: .largeTitle) }
    static var fogHeading: Font { .fogCustom(.dmSansBold, size: 22, relativeTo: .title) }
    static var fogButton: Font { .fogCustom(.dmSansSemiBold, size: 16, relativeTo: .headline) }
    static var fogBody: Font { .fogCustom(.dmSansRegular, size: 14, relativeTo: .body) }
    static var fogCaption: Font { .fogCustom(.dmSansMedium, size: 13, relativeTo: .callout) }
    static var fogMicro: Font { .fogCustom(.dmSansRegular, size: 11, relativeTo: .caption) }

    // MARK: - IBM Plex Mono (fixed sizes — mirror prototype)

    static var fogMonoXL: Font { .fogCustom(.plexMonoSemiBold, size: 24) }
    static var fogMonoLg: Font { .fogCustom(.plexMonoSemiBold, size: 20) }
    static var fogMonoMd: Font { .fogCustom(.plexMonoMedium, size: 14) }
    static var fogMonoSm: Font { .fogCustom(.plexMonoMedium, size: 11) }
    static var fogMonoCap: Font { .fogCustom(.plexMonoMedium, size: 9) }
}

// MARK: - Font face registry

public enum FogRideFont: String, CaseIterable, Sendable {
    case dmSansRegular = "DMSans-Regular"
    case dmSansMedium = "DMSans-Medium"
    case dmSansSemiBold = "DMSans-SemiBold"
    case dmSansBold = "DMSans-Bold"
    case plexMonoRegular = "IBMPlexMono-Regular"
    case plexMonoMedium = "IBMPlexMono-Medium"
    case plexMonoSemiBold = "IBMPlexMono-SemiBold"

    var isMonospaced: Bool {
        switch self {
        case .plexMonoRegular, .plexMonoMedium, .plexMonoSemiBold:
            return true
        default:
            return false
        }
    }
}

extension Font {

    static func fogCustom(_ face: FogRideFont, size: CGFloat, relativeTo textStyle: Font.TextStyle? = nil) -> Font {
        _ = FogRideFontRegistrar.ensureRegistered
        if let relative = textStyle {
            return .custom(face.rawValue, size: size, relativeTo: relative)
        } else {
            return .custom(face.rawValue, fixedSize: size)
        }
    }
}

// MARK: - Registrar

public enum FogRideFontRegistrar {

    /// Idempotent registration. Access this property once to register all bundled fonts.
    public static let ensureRegistered: Void = {
        register()
    }()

    /// Public manual re-entry — safe to call multiple times.
    public static func register() {
        for face in FogRideFont.allCases {
            registerFace(face)
        }
    }

    private static func registerFace(_ face: FogRideFont) {
        guard let url = Bundle.module.url(forResource: face.rawValue, withExtension: "ttf") else {
            #if DEBUG
            print("[FogRideFontRegistrar] Missing font resource: \(face.rawValue).ttf — falling back to system font.")
            #endif
            return
        }
        var errorRef: Unmanaged<CFError>?
        if !CTFontManagerRegisterFontsForURL(url as CFURL, .process, &errorRef) {
            #if DEBUG
            let err = errorRef?.takeRetainedValue()
            let code = err.map { CFErrorGetCode($0) } ?? -1
            // Code 105 = "font already registered" — benign on repeated calls.
            if code != 105 {
                print("[FogRideFontRegistrar] Failed to register \(face.rawValue): \(String(describing: err))")
            }
            #endif
        }
    }
}

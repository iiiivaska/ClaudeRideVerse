import CoreLocation
import DesignSystem
import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0
    @State private var locationManager = CLLocationManager()

    var body: some View {
        ZStack {
            Color.fogBg.ignoresSafeArea()

            VStack(spacing: FogSpacing.xl) {
                Spacer()

                pageContent

                OnboardingDots(activeIndex: page, total: 2)
                    .padding(.bottom, FogSpacing.s)

                pageTitle

                Spacer()

                pageButtons
                    .padding(.bottom, FogSpacing.xxl)
            }
            .padding(.horizontal, FogSpacing.xl)
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut(duration: 0.35), value: page)
    }

    // MARK: - Page Content

    @ViewBuilder
    private var pageContent: some View {
        switch page {
        case 0:
            HexGridIllustration()
                .frame(height: 200)
                .transition(.opacity)
        default:
            OBIconContainer(tone: .accent) {
                Image(systemName: "location.fill")
                    .font(.system(size: 36, weight: .regular))
                    .foregroundStyle(Color.fogAccent)
            }
            .transition(.opacity)
        }
    }

    // MARK: - Titles

    @ViewBuilder
    private var pageTitle: some View {
        switch page {
        case 0:
            VStack(spacing: FogSpacing.s) {
                Text("Discover where you've ridden")
                    .font(.fogTitleL)
                    .foregroundStyle(Color.fogTextPrimary)
                    .multilineTextAlignment(.center)

                Text("RideVerse turns every ride into exploration.\nCover the map, hex by hex.")
                    .font(.fogBody)
                    .foregroundStyle(Color.fogTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .transition(.opacity)

        default:
            VStack(spacing: FogSpacing.s) {
                Text("Show your rides on the map")
                    .font(.fogTitleL)
                    .foregroundStyle(Color.fogTextPrimary)
                    .multilineTextAlignment(.center)

                Text("We need your location to record GPS tracks during rides. Your data stays on your device.")
                    .font(.fogBody)
                    .foregroundStyle(Color.fogTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .transition(.opacity)
        }
    }

    // MARK: - Buttons

    @ViewBuilder
    private var pageButtons: some View {
        switch page {
        case 0:
            VStack(spacing: FogSpacing.m) {
                Button("Get started") {
                    page = 1
                }
                .buttonStyle(.fogPrimary)
            }

        default:
            VStack(spacing: FogSpacing.m) {
                Button("Allow location access") {
                    locationManager.requestWhenInUseAuthorization()
                    onComplete()
                }
                .buttonStyle(.fogPrimary)

                Button("Not now") {
                    onComplete()
                }
                .buttonStyle(.fogLink)
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}

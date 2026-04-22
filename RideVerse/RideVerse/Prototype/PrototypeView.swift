import CoreLocation
import DesignSystem
import LocationRecording
import MapCore
import SwiftUI

/// Single-screen prototype: map + fog-of-war + Start/Stop + hex counter.
struct PrototypeView: View {
    @State private var viewModel = PrototypeViewModel()

    private var mapStyle: MapStyle {
        MapStyle.stadiaOutdoorsFromEnvironment() ?? .openFreeMap
    }

    var body: some View {
        ZStack {
            mapLayer
            overlayUI
        }
        .preferredColorScheme(.dark)
        .onChange(of: viewModel.visibleBBox) { _, _ in
            viewModel.handleVisibleBoundsChange()
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        PrototypeMapView(
            camera: $viewModel.camera,
            visibleBBox: $viewModel.visibleBBox,
            style: mapStyle,
            fogFeatures: viewModel.fogFeatures,
            onUserGesture: { viewModel.userDidPan() }
        )
        .ignoresSafeArea()
    }

    // MARK: - Overlay UI

    private var overlayUI: some View {
        VStack(spacing: FogSpacing.m) {
            hexCounterPill
                .padding(.top, FogSpacing.s)

            Spacer()

            if viewModel.recordingState == .recording {
                recordingHUD
            }

            bottomControls
                .padding(.bottom, FogSpacing.m)
        }
        .padding(.horizontal, FogSpacing.m)
    }

    // MARK: - Hex Counter

    private var hexCounterPill: some View {
        HStack(spacing: FogSpacing.s) {
            GlassPill {
                Image(systemName: "hexagon.fill")
                    .foregroundStyle(Color.fogAccent)
                MonoVal("\(viewModel.hexCount)", size: .lg, color: .fogAccent)
                MonoLabel("HEX")
            }

            if viewModel.recordingState == .recording {
                GlassPill {
                    Image(systemName: "record.circle")
                        .foregroundStyle(Color.fogRed)
                    MonoVal(formattedTime, size: .md, color: .fogTextPrimary)
                }
            }

            Spacer()

            if viewModel.recordingState == .recording, !viewModel.isTracking {
                recenterButton
            }
        }
    }

    // MARK: - Recording HUD

    private var recordingHUD: some View {
        GlassHUDCard {
            HStack(spacing: FogSpacing.l) {
                VStack(spacing: FogSpacing.xxs) {
                    MonoVal("\(viewModel.hexCount)", size: .xl, color: .fogAccent)
                    MonoLabel("HEX")
                }
                VStack(spacing: FogSpacing.xxs) {
                    MonoVal(formattedTime, size: .xl, color: .fogTextPrimary)
                    MonoLabel("TIME")
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Bottom Controls

    @ViewBuilder
    private var bottomControls: some View {
        if viewModel.recordingState == .idle {
            Button("Start Ride", systemImage: "bicycle") {
                viewModel.startRecording()
            }
            .buttonStyle(.fogPrimary)
        } else {
            StopButton {
                viewModel.stopRecording()
            }
        }
    }

    // MARK: - Recenter Button

    private var recenterButton: some View {
        Button {
            viewModel.recenter()
        } label: {
            Image(systemName: "location.fill")
                .font(.fogBody)
                .foregroundStyle(Color.fogAccent)
                .frame(width: 44, height: 44)
        }
        .clipShape(.rect(cornerRadius: FogRadius.pill, style: .continuous))
        .fogGlass(level: .control)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = viewModel.elapsedSeconds / 60
        let seconds = viewModel.elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    PrototypeView()
}

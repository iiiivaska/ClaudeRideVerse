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
        .sheet(item: $viewModel.rideSummary) { summary in
            RideSummaryView(summary: summary) {
                viewModel.dismissSummary()
            }
            .interactiveDismissDisabled()
        }
    }

    // MARK: - Map Layer

    private var mapLayer: some View {
        PrototypeMapView(
            camera: $viewModel.camera,
            visibleBBox: $viewModel.visibleBBox,
            userLocation: $viewModel.mapUserLocation,
            style: mapStyle,
            fogFeatures: viewModel.fogFeatures,
            trackCoordinates: viewModel.trackCoordinates,
            isTracking: viewModel.isTracking,
            onUserGesture: { viewModel.userDidPan() }
        )
        .ignoresSafeArea()
    }

    // MARK: - Overlay UI

    private var isRecording: Bool {
        viewModel.recordingState == .recording || viewModel.recordingState == .paused
    }

    private var overlayUI: some View {
        ZStack {
            VStack(spacing: FogSpacing.m) {
                topBar
                    .padding(.top, FogSpacing.s)

                Spacer()

                if isRecording {
                    recordingHUD
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                bottomControls
                    .padding(.bottom, FogSpacing.m)
            }
            .padding(.horizontal, FogSpacing.m)

            // Recenter button — right edge (always visible unless actively tracking)
            if !viewModel.isTracking || !isRecording {
                VStack {
                    Spacer()
                        .frame(maxHeight: .infinity)
                    recenterButton
                    Spacer()
                        .frame(maxHeight: .infinity)
                    Spacer()
                        .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing, FogSpacing.m)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.35), value: isRecording)
        .animation(.easeOut(duration: 0.25), value: viewModel.isTracking)
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: FogSpacing.s) {
            GlassPill {
                Image(systemName: "hexagon.fill")
                    .foregroundStyle(Color.fogAccent)
                MonoVal("\(viewModel.hexCount)", size: .lg, color: .fogAccent)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: viewModel.hexCount)
                MonoLabel("HEX")
            }

            if isRecording {
                recPill
                    .transition(.opacity.combined(with: .scale(scale: 0.8)))
            } else if viewModel.gpsState == .searching {
                GlassPill {
                    ProgressView()
                        .tint(Color.fogAccent)
                        .controlSize(.small)
                    MonoVal("GPS...", size: .sm, color: .fogTextSecondary)
                }
                .transition(.opacity)
            }

            Spacer()
        }
    }

    // MARK: - REC Pill

    private var recPill: some View {
        GlassPill {
            RecPulseDot()
            MonoVal(viewModel.isPaused ? "PAUSED" : "REC", size: .sm, color: .fogTextPrimary)
            Text("\u{00B7}")
                .foregroundStyle(Color.fogTextTertiary)
            MonoVal(formattedTime, size: .sm, color: .fogTextPrimary)
        }
    }

    // MARK: - Recording HUD

    private var recordingHUD: some View {
        GlassHUDCard {
            MetricCell4Grid(cells: [
                .init(value: formattedSpeed, label: "KM/H"),
                .init(value: "\(viewModel.hexCount)", label: "HEX", valueColor: .fogAccent),
                .init(value: formattedDistance, label: "KM"),
                .init(value: formattedTime, label: "TIME"),
            ])
        }
    }

    // MARK: - Bottom Controls

    @ViewBuilder
    private var bottomControls: some View {
        if viewModel.recordingState == .idle {
            Button("Start Ride", systemImage: "bicycle") {
                withAnimation(.easeInOut(duration: 0.35)) {
                    viewModel.startRecording()
                }
            }
            .buttonStyle(.fogPrimary)
        } else {
            HStack(spacing: FogSpacing.m) {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        if viewModel.isPaused {
                            viewModel.resumeRecording()
                        } else {
                            viewModel.pauseRecording()
                        }
                    }
                } label: {
                    Label(
                        viewModel.isPaused ? "Resume" : "Pause",
                        systemImage: viewModel.isPaused ? "play.fill" : "pause.fill"
                    )
                }
                .buttonStyle(.fogSecondary)

                StopButton {
                    withAnimation(.easeInOut(duration: 0.35)) {
                        viewModel.stopRecording()
                    }
                }
            }
        }
    }

    // MARK: - Recenter Button

    private var recenterButton: some View {
        Button {
            viewModel.recenter()
        } label: {
            GlassCircle {
                Image(systemName: "location.fill")
                    .font(.fogBody)
                    .foregroundStyle(Color.fogAccent)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Helpers

    private var formattedTime: String {
        let minutes = viewModel.elapsedSeconds / 60
        let seconds = viewModel.elapsedSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    private var formattedSpeed: String {
        String(format: "%.1f", viewModel.speed)
    }

    private var formattedDistance: String {
        let km = viewModel.totalDistance / 1000
        return km >= 10 ? String(format: "%.0f", km) : String(format: "%.1f", km)
    }
}

#Preview {
    PrototypeView()
}

import CoreLocation
import DesignSystem
import SwiftUI

struct RideSummaryView: View {
    let summary: RideSummary
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: FogSpacing.xl) {
            Spacer()

            checkmark
            title

            StatCard2x2(cells: [
                .init(value: formattedDistance, label: "DISTANCE"),
                .init(value: "+\(summary.hexCount)", label: "NEW HEX", valueColor: .fogAccent),
                .init(value: formattedDuration, label: "MOVING"),
                .init(value: formattedAvgSpeed, label: "AVG SPEED"),
            ])

            if summary.trackCoordinates.count >= 2 {
                trackPreview
            }

            Spacer()

            Button("Done") { onDismiss() }
                .buttonStyle(.fogPrimary)
                .padding(.bottom, FogSpacing.xxl)
        }
        .padding(.horizontal, FogSpacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.fogBg)
        .preferredColorScheme(.dark)
    }

    // MARK: - Checkmark

    private var checkmark: some View {
        ZStack {
            Circle()
                .fill(Color.fogGreen)
                .frame(width: 64, height: 64)
                .shadow(color: .fogGreen.opacity(0.4), radius: 16, y: 4)

            Image(systemName: "checkmark")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    // MARK: - Title

    private var title: some View {
        Text("Ride complete")
            .font(.fogTitleL)
            .foregroundStyle(Color.fogTextPrimary)
    }

    // MARK: - Track Preview

    private var trackPreview: some View {
        Canvas { context, canvasSize in
            let coords = summary.trackCoordinates
            guard coords.count >= 2 else { return }

            let lats = coords.map(\.latitude)
            let lons = coords.map(\.longitude)
            guard let minLat = lats.min(), let maxLat = lats.max(),
                  let minLon = lons.min(), let maxLon = lons.max() else { return }

            let latSpan = max(maxLat - minLat, 0.0001)
            let lonSpan = max(maxLon - minLon, 0.0001)
            let padding: CGFloat = 20

            let drawW = canvasSize.width - padding * 2
            let drawH = canvasSize.height - padding * 2

            func point(for coord: CLLocationCoordinate2D) -> CGPoint {
                let x = padding + (coord.longitude - minLon) / lonSpan * drawW
                let y = padding + (1 - (coord.latitude - minLat) / latSpan) * drawH
                return CGPoint(x: x, y: y)
            }

            // Track line
            var path = Path()
            path.move(to: point(for: coords[0]))
            for coord in coords.dropFirst() {
                path.addLine(to: point(for: coord))
            }
            context.stroke(path, with: .color(.fogAccent), lineWidth: 2.5)

            // Start dot (green)
            let startPt = point(for: coords[0])
            context.fill(
                Path(ellipseIn: CGRect(x: startPt.x - 4, y: startPt.y - 4, width: 8, height: 8)),
                with: .color(.fogGreen)
            )

            // End dot (red)
            let endPt = point(for: coords[coords.count - 1])
            context.fill(
                Path(ellipseIn: CGRect(x: endPt.x - 4, y: endPt.y - 4, width: 8, height: 8)),
                with: .color(.fogRed)
            )
        }
        .frame(height: 110)
        .background(Color.fogSurface1, in: .rect(cornerRadius: FogRadius.xl, style: .continuous))
    }

    // MARK: - Formatting

    private var formattedDistance: String {
        let km = summary.distance / 1000
        return km >= 10 ? String(format: "%.0f km", km) : String(format: "%.1f km", km)
    }

    private var formattedDuration: String {
        let m = summary.elapsedSeconds / 60
        let s = summary.elapsedSeconds % 60
        return String(format: "%d:%02d", m, s)
    }

    private var formattedAvgSpeed: String {
        guard summary.elapsedSeconds > 0 else { return "0.0" }
        let kmh = (summary.distance / 1000) / (Double(summary.elapsedSeconds) / 3600)
        return String(format: "%.1f", kmh)
    }
}

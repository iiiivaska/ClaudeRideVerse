import SwiftUI

/// Four-column metric strip — value on top (MonoVal), caps label below
/// (MonoLabel), 1pt vertical separators between columns. Used inside the
/// Recording HUD.
public struct MetricCell4Grid: View {

    public struct Cell: Identifiable, Sendable {
        public let id: UUID
        public let value: String
        public let label: String
        public let valueColor: Color

        public init(id: UUID = UUID(), value: String, label: String, valueColor: Color = .fogTextPrimary) {
            self.id = id
            self.value = value
            self.label = label
            self.valueColor = valueColor
        }
    }

    private let cells: [Cell]
    private let valueSize: MonoVal.Size

    public init(cells: [Cell], valueSize: MonoVal.Size = .lg) {
        precondition(cells.count == 4, "MetricCell4Grid requires exactly 4 cells (found \(cells.count))")
        self.cells = cells
        self.valueSize = valueSize
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(cells.enumerated()), id: \.element.id) { index, cell in
                VStack(alignment: .center, spacing: FogSpacing.xxs) {
                    MonoVal(cell.value, size: valueSize, color: cell.valueColor)
                    MonoLabel(cell.label)
                }
                .frame(maxWidth: .infinity)

                if index < cells.count - 1 {
                    Rectangle()
                        .fill(Color.fogSeparator)
                        .frame(width: 1, height: 28)
                }
            }
        }
    }
}

#Preview("MetricCell4Grid") {
    GlassHUDCard {
        MetricCell4Grid(cells: [
            .init(value: "18.3", label: "km/h"),
            .init(value: "342", label: "hex", valueColor: .fogAccent),
            .init(value: "1:23", label: "moving"),
            .init(value: "+47", label: "elev", valueColor: .fogGreen),
        ])
    }
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

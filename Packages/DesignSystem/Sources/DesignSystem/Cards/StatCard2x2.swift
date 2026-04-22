import SwiftUI

/// 2×2 stat grid used by Trip Summary and Trip Detail. Each cell hosts a
/// MonoVal on top and a MonoLabel below, separated by 1pt hairlines.
public struct StatCard2x2: View {

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

    public init(cells: [Cell], valueSize: MonoVal.Size = .xl) {
        precondition(cells.count == 4, "StatCard2x2 requires exactly 4 cells (found \(cells.count))")
        self.cells = cells
        self.valueSize = valueSize
    }

    public var body: some View {
        VStack(spacing: 1) {
            row(indexes: 0..<2)
            Rectangle().fill(Color.fogSeparator).frame(height: 1)
            row(indexes: 2..<4)
        }
        .background(Color.fogSurface1, in: .rect(cornerRadius: FogRadius.xl, style: .continuous))
    }

    private func row(indexes: Range<Int>) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(indexes), id: \.self) { index in
                VStack(spacing: FogSpacing.xxs) {
                    MonoVal(cells[index].value, size: valueSize, color: cells[index].valueColor)
                    MonoLabel(cells[index].label)
                }
                .frame(maxWidth: .infinity)
                .padding(FogSpacing.m)

                if index == indexes.lowerBound {
                    Rectangle().fill(Color.fogSeparator).frame(width: 1)
                }
            }
        }
    }
}

#Preview("StatCard2x2") {
    StatCard2x2(cells: [
        .init(value: "18.3", label: "distance"),
        .init(value: "342", label: "hex", valueColor: .fogAccent),
        .init(value: "1:23", label: "moving"),
        .init(value: "+47", label: "elev", valueColor: .fogGreen),
    ])
    .padding()
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.fogBg)
    .preferredColorScheme(.dark)
}

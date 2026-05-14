import SwiftUI

struct ClassicCellView: View {
    @Environment(\.squartPalette) private var palette

    let state: CellState
    let isHintedOrigin: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(fillColor)
                .overlay(symbol)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(borderColor, lineWidth: isHintedOrigin ? 1.5 : 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.94, pressedOpacity: 0.90))
    }

    @ViewBuilder
    private var symbol: some View {
        switch state {
        case .occupied:
            EmptyView()
        case .empty, .inactive, .outside:
            EmptyView()
        }
    }

    private var fillColor: Color {
        switch state {
        case .outside:
            return Color.clear
        case .inactive:
            return palette.blockerCell
        case .empty:
            return palette.panel
        case .occupied:
            return palette.panel
        }
    }

    private var borderColor: Color {
        switch state {
        case .outside:
            return Color.clear
        case .inactive:
            return palette.blockerCellBorder
        case .empty:
            return isHintedOrigin ? palette.accent.opacity(0.62) : palette.subtleBorder
        case .occupied:
            return palette.subtleBorder
        }
    }
}

#Preview {
    HStack {
        ClassicCellView(state: .outside, isHintedOrigin: false) {}
        ClassicCellView(state: .empty, isHintedOrigin: true) {}
        ClassicCellView(state: .inactive, isHintedOrigin: false) {}
        ClassicCellView(state: .occupied(.horizontal), isHintedOrigin: false) {}
        ClassicCellView(state: .occupied(.vertical), isHintedOrigin: false) {}
    }
    .frame(height: 48)
    .padding()
    .background(SquartVisualTheme.defaultTheme.palette.backgroundBottom)
}

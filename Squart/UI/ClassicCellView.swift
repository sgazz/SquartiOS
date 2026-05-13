import SwiftUI

struct ClassicCellView: View {
    @Environment(\.squartPalette) private var palette

    let state: CellState
    let isValidOrigin: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: 5, style: .continuous)
                .fill(fillColor)
                .overlay(symbol)
                .overlay(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .stroke(borderColor, lineWidth: isValidOrigin ? 1.5 : 1)
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.94, pressedOpacity: 0.90))
    }

    @ViewBuilder
    private var symbol: some View {
        switch state {
        case .occupied(.horizontal):
            GeometryReader { proxy in
                Capsule()
                    .fill(palette.accent.opacity(0.86))
                    .frame(width: proxy.size.width * 0.68, height: max(4, proxy.size.height * 0.18))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .occupied(.vertical):
            GeometryReader { proxy in
                Capsule()
                    .fill(palette.coolAccent.opacity(0.9))
                    .frame(width: max(4, proxy.size.width * 0.18), height: proxy.size.height * 0.68)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        case .empty, .inactive, .outside:
            EmptyView()
        }
    }

    private var fillColor: Color {
        switch state {
        case .outside:
            return Color.clear
        case .inactive:
            return palette.secondaryAccent.opacity(0.34)
        case .empty:
            return palette.panel
        case .occupied(.horizontal):
            return palette.secondaryAccent.opacity(0.92)
        case .occupied(.vertical):
            return palette.coolAccent.opacity(0.38)
        }
    }

    private var borderColor: Color {
        switch state {
        case .outside:
            return Color.clear
        case .inactive:
            return palette.accent.opacity(0.18)
        case .empty:
            return isValidOrigin ? palette.accent.opacity(0.78) : palette.subtleBorder
        case .occupied(.horizontal):
            return palette.accent.opacity(0.42)
        case .occupied(.vertical):
            return palette.coolAccent.opacity(0.40)
        }
    }
}

#Preview {
    HStack {
        ClassicCellView(state: .outside, isValidOrigin: false) {}
        ClassicCellView(state: .empty, isValidOrigin: true) {}
        ClassicCellView(state: .inactive, isValidOrigin: false) {}
        ClassicCellView(state: .occupied(.horizontal), isValidOrigin: false) {}
        ClassicCellView(state: .occupied(.vertical), isValidOrigin: false) {}
    }
    .frame(height: 48)
    .padding()
    .background(SquartVisualTheme.defaultTheme.palette.backgroundBottom)
}

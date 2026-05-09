import SwiftUI

struct CellDebugView: View {
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
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var symbol: some View {
        switch state {
        case .occupied(.horizontal):
            Capsule()
                .fill(Color(red: 0.96, green: 0.82, blue: 0.62).opacity(0.86))
                .frame(width: 22, height: 6)
        case .occupied(.vertical):
            Capsule()
                .fill(Color(red: 0.58, green: 0.68, blue: 0.72).opacity(0.9))
                .frame(width: 6, height: 22)
        case .empty, .inactive, .outside:
            EmptyView()
        }
    }

    private var fillColor: Color {
        switch state {
        case .outside:
            return Color.clear
        case .inactive:
            return Color(red: 0.18, green: 0.14, blue: 0.10).opacity(0.44)
        case .empty:
            return Color.white.opacity(0.09)
        case .occupied(.horizontal):
            return Color(red: 0.42, green: 0.31, blue: 0.22).opacity(0.92)
        case .occupied(.vertical):
            return Color(red: 0.20, green: 0.27, blue: 0.29).opacity(0.94)
        }
    }

    private var borderColor: Color {
        switch state {
        case .outside:
            return Color.clear
        case .inactive:
            return Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.18)
        case .empty:
            return isValidOrigin ? Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.78) : Color.white.opacity(0.10)
        case .occupied(.horizontal):
            return Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.42)
        case .occupied(.vertical):
            return Color(red: 0.58, green: 0.68, blue: 0.72).opacity(0.40)
        }
    }
}

#Preview {
    HStack {
        CellDebugView(state: .outside, isValidOrigin: false) {}
        CellDebugView(state: .empty, isValidOrigin: true) {}
        CellDebugView(state: .inactive, isValidOrigin: false) {}
        CellDebugView(state: .occupied(.horizontal), isValidOrigin: false) {}
        CellDebugView(state: .occupied(.vertical), isValidOrigin: false) {}
    }
    .frame(height: 48)
    .padding()
    .background(Color.black)
}

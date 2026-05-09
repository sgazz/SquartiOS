import SwiftUI

struct PlayerBadgeView: View {
    let player: Player
    let isThinking: Bool

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(accentColor)
                .frame(width: 22, height: 7)

            Text(isThinking ? "AI studying the board..." : "\(player.displayName) to move")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(
            Capsule()
                .fill(SquartTheme.Colors.panelGraphite)
                .overlay(Capsule().stroke(accentColor.opacity(0.30), lineWidth: 1))
        )
    }

    private var accentColor: Color {
        switch player {
        case .horizontal:
            return SquartTheme.Colors.cappuccino
        case .vertical:
            return SquartTheme.Colors.steel
        }
    }
}

import SwiftUI

struct PlayerBadgeView: View {
    @Environment(\.squartPalette) private var palette

    let player: Player
    let isThinking: Bool

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(accentColor)
                .frame(width: 22, height: 7)

            Text(isThinking ? "AI studying the board..." : "\(player.displayName) to move")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.strongText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .contentTransition(.opacity)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(
            Capsule()
                .fill(palette.panel)
                .overlay(Capsule().stroke(accentColor.opacity(0.30), lineWidth: 1))
        )
        .animation(SquartTheme.microInteractionAnimation, value: player)
        .animation(SquartTheme.microInteractionAnimation, value: isThinking)
    }

    private var accentColor: Color {
        switch player {
        case .horizontal:
            return palette.accent
        case .vertical:
            return palette.coolAccent
        }
    }
}

import SwiftUI

struct PlayerBadgeView: View {
    let player: Player
    let isThinking: Bool

    var body: some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(accentColor)
                .frame(width: 22, height: 7)

            Text(isThinking ? "AI thinking..." : "\(player.displayName) to move")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(.horizontal, 12)
        .frame(height: 34)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.07))
                .overlay(Capsule().stroke(accentColor.opacity(0.30), lineWidth: 1))
        )
    }

    private var accentColor: Color {
        switch player {
        case .horizontal:
            return Color(red: 0.78, green: 0.66, blue: 0.52)
        case .vertical:
            return Color(red: 0.58, green: 0.68, blue: 0.70)
        }
    }
}

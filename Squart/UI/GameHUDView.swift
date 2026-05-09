import SwiftUI

struct GameHUDView: View {
    let configuration: GameConfiguration
    let currentPlayer: Player
    let isAITurnPending: Bool
    let moveCount: Int

    @Binding var boardMode: GameBoardMode

    let onResetGame: () -> Void
    let onResetCamera: () -> Void
    let onChangeSetup: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Squart")
                        .font(.system(size: 28, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.94))

                    PlayerBadgeView(player: currentPlayer, isThinking: isAITurnPending)
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(moveCount) moves")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.78, green: 0.66, blue: 0.52))

                    Text(summaryText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.trailing)
                        .lineLimit(2)
                }
            }

            Picker("Board Mode", selection: $boardMode) {
                ForEach(GameBoardMode.allCases) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .tint(Color(red: 0.78, green: 0.66, blue: 0.52))

            HStack(spacing: 10) {
                Button(action: onResetGame) {
                    HUDButtonLabel(title: "Reset Game")
                }
                .buttonStyle(.plain)

                Button(action: onChangeSetup) {
                    HUDButtonLabel(title: "Setup")
                }
                .buttonStyle(.plain)

                if boardMode == .preview3D {
                    Button(action: onResetCamera) {
                        HUDButtonLabel(title: "Reset Camera")
                    }
                    .buttonStyle(.plain)
                    .transition(.opacity)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.055))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.white.opacity(0.09), lineWidth: 1)
                )
        )
        .padding(.horizontal, 16)
    }

    private var summaryText: String {
        let shape = configuration.boardShape.displayName
        let size = "\(configuration.boardSize)x\(configuration.boardSize)"
        let inactive = "\(Int((configuration.inactiveCellRatio * 100).rounded()))%"

        switch configuration.mode {
        case .pvp:
            return "PvP / \(shape) / \(size) / \(inactive)"
        case .playerVsAI:
            return "AI \(configuration.aiDifficulty.rawValue) / \(shape) / \(size) / \(inactive)"
        }
    }
}

private struct HUDButtonLabel: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(.white.opacity(0.86))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    .background(Capsule().fill(Color.white.opacity(0.045)))
            )
    }
}

private extension BoardShape {
    var displayName: String {
        switch self {
        case .square:
            return "Square"
        case .diamond:
            return "Diamond"
        case .rectangle:
            return "Rectangle"
        case .triangle:
            return "Triangle"
        case .circle:
            return "Circle"
        case .hexagon:
            return "Hexagon"
        case .star:
            return "Star"
        case .asymmetric:
            return "Asymmetric"
        case .random:
            return "Random"
        }
    }
}

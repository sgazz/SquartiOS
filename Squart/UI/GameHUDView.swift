import SwiftUI

struct GameHUDView: View {
    let configuration: GameConfiguration
    let currentPlayer: Player
    let isAITurnPending: Bool
    let moveCount: Int
    let canUndo: Bool

    @Binding var boardMode: GameBoardMode

    let onUndoLastMove: () -> Void
    let onResetGame: () -> Void
    let onResetCamera: () -> Void
    let onChangeSetup: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Squart")
                        .font(SquartTheme.titleFont(size: 28))
                        .foregroundStyle(SquartTheme.Colors.primaryText)

                    PlayerBadgeView(player: currentPlayer, isThinking: isAITurnPending)
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(moveCount) moves")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(SquartTheme.Colors.cappuccino)

                    Text(summaryText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(SquartTheme.Colors.mutedText)
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
            .tint(SquartTheme.Colors.cappuccino)

            HStack(spacing: 10) {
                Button(action: onUndoLastMove) {
                    HUDButtonLabel(title: "Undo", isEnabled: canUndo)
                }
                .buttonStyle(.plain)
                .disabled(!canUndo)

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
        .squartCard(cornerRadius: 16, fill: SquartTheme.Colors.panelGraphite, stroke: SquartTheme.Colors.borderGraphite)
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
    var isEnabled = true

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(Color.white.opacity(isEnabled ? 0.86 : 0.34))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    .background(Capsule().fill(SquartTheme.Colors.subtlePanelGraphite.opacity(isEnabled ? 1 : 0.56)))
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

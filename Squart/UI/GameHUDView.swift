import SwiftUI

struct GameHUDView: View {
    @Environment(\.squartPalette) private var palette

    let configuration: GameConfiguration
    let currentPlayer: Player
    let isAITurnPending: Bool
    let moveCount: Int
    let canUndo: Bool

    @Binding var boardMode: GameBoardMode

    let onUndoLastMove: () -> Void
    let onResetGame: () -> Void
    let onResetCamera: () -> Void
    let onRotateBoardLeft: () -> Void
    let onRotateBoardRight: () -> Void
    let onChangeSetup: () -> Void

    var body: some View {
        VStack(spacing: 14) {
            HStack(alignment: .center, spacing: 12) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("Squart")
                        .font(SquartTheme.titleFont(size: 28))
                        .foregroundStyle(palette.primaryText)

                    PlayerBadgeView(player: currentPlayer, isThinking: isAITurnPending)
                }

                Spacer(minLength: 10)

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(moveCount) moves")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(palette.accent)

                    Text(summaryText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.mutedText)
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
            .tint(palette.accent)
            .onChange(of: boardMode) { _, _ in
                Haptics.selection()
            }

            HStack(spacing: 10) {
                Button(action: onUndoLastMove) {
                    HUDButtonLabel(title: "Undo", isEnabled: canUndo)
                }
                .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.975, pressedOpacity: 0.80))
                .disabled(!canUndo)

                Button(action: onResetGame) {
                    HUDButtonLabel(title: "Reset Game")
                }
                .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.975, pressedOpacity: 0.82))

                Button(action: onChangeSetup) {
                    HUDButtonLabel(title: "Setup")
                }
                .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.975, pressedOpacity: 0.82))

                if boardMode == .board3D {
                    Button(action: onRotateBoardLeft) {
                        HUDButtonLabel(title: "Left 90")
                    }
                    .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.975, pressedOpacity: 0.82))
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .trailing)))

                    Button(action: onRotateBoardRight) {
                        HUDButtonLabel(title: "Right 90")
                    }
                    .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.975, pressedOpacity: 0.82))
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .trailing)))

                    Button(action: onResetCamera) {
                        HUDButtonLabel(title: "Reset Camera")
                    }
                    .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.975, pressedOpacity: 0.82))
                    .transition(.opacity.combined(with: .scale(scale: 0.98, anchor: .trailing)))
                }
            }
        }
        .padding(16)
        .squartCard(cornerRadius: 16, fill: palette.panel, stroke: palette.border)
        .padding(.horizontal, 16)
        .animation(SquartTheme.microInteractionAnimation, value: boardMode)
        .animation(SquartTheme.microInteractionAnimation, value: canUndo)
        .animation(SquartTheme.microInteractionAnimation, value: isAITurnPending)
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
    @Environment(\.squartPalette) private var palette

    let title: String
    var isEnabled = true

    var body: some View {
        Text(title)
            .font(.system(size: 13, weight: .medium))
            .foregroundStyle(isEnabled ? palette.bodyText : palette.quietText.opacity(0.72))
            .lineLimit(1)
            .minimumScaleFactor(0.78)
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(
                Capsule()
                    .stroke(palette.border, lineWidth: 1)
                    .background(Capsule().fill(palette.subtlePanel.opacity(isEnabled ? 1 : 0.56)))
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

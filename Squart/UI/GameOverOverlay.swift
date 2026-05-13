import SwiftUI

struct GameOverOverlay: View {
    @Environment(\.squartPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var hasAppeared = false

    let winner: Player
    let stats: MatchStats
    let onUndo: (() -> Void)?
    let onRematch: () -> Void
    let onChangeSetup: () -> Void

    var body: some View {
        ZStack {
            palette.backgroundBottom.opacity(0.56)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                VStack(spacing: 8) {
                    Text("Game Over")
                        .font(SquartTheme.titleFont(size: 34))
                        .foregroundStyle(palette.primaryText)

                    Text("\(winner.displayName) wins")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(palette.accent)

                    Text(resultLine)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .multilineTextAlignment(.center)
                }

                MatchStatsView(stats: stats)

                VStack(spacing: 10) {
                    if let onUndo {
                        Button(action: onUndo) {
                            OverlaySecondaryButtonLabel(title: "Undo", width: 286)
                        }
                        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.985, pressedOpacity: 0.82))
                    }

                    HStack(spacing: 12) {
                        Button(action: onRematch) {
                            Text("Rematch")
                        }
                        .buttonStyle(SquartPrimaryButtonStyle(width: 132, height: 48))

                        Button(action: onChangeSetup) {
                            OverlaySecondaryButtonLabel(title: "Change Setup", width: 142)
                        }
                        .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.985, pressedOpacity: 0.82))
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 390)
            .background(
                RoundedRectangle(cornerRadius: SquartTheme.Radius.overlay, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: SquartTheme.Radius.overlay, style: .continuous)
                            .fill(palette.sheetBackground.opacity(0.72))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: SquartTheme.Radius.overlay, style: .continuous)
                            .stroke(palette.accent.opacity(0.22), lineWidth: 1)
                    )
            )
            .padding(24)
            .scaleEffect(hasAppeared || reduceMotion ? 1 : 0.985)
            .opacity(hasAppeared ? 1 : 0)
            .onAppear {
                withAnimation(reduceMotion ? nil : SquartTheme.microInteractionAnimation) {
                    hasAppeared = true
                }
            }
        }
    }

    private var resultLine: String {
        switch winner {
        case .horizontal:
            return "Horizontal controlled the final space."
        case .vertical:
            return "Vertical closed the board."
        }
    }
}

struct MatchStats: Equatable {
    let totalMoves: Int
    let horizontalMoves: Int
    let verticalMoves: Int
    let boardText: String
    let modeText: String
}

private struct MatchStatsView: View {
    @Environment(\.squartPalette) private var palette

    let stats: MatchStats

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                MatchStatPill(title: "Moves", value: "\(stats.totalMoves)")
                MatchStatPill(title: "Horizontal", value: "\(stats.horizontalMoves)")
                MatchStatPill(title: "Vertical", value: "\(stats.verticalMoves)")
            }

            VStack(spacing: 5) {
                MatchStatLine(title: "Board", value: stats.boardText)
                MatchStatLine(title: "Mode", value: stats.modeText)
            }
        }
        .padding(12)
        .squartCard(fill: palette.panel)
    }
}

private struct MatchStatPill: View {
    @Environment(\.squartPalette) private var palette

    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(palette.quietText)

            Text(value)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(palette.accent)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct MatchStatLine: View {
    @Environment(\.squartPalette) private var palette

    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(palette.quietText)
                .frame(width: 42, alignment: .leading)

            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(palette.bodyText)
                .lineLimit(1)
                .minimumScaleFactor(0.82)

            Spacer(minLength: 0)
        }
    }
}

private struct OverlaySecondaryButtonLabel: View {
    @Environment(\.squartPalette) private var palette

    let title: String
    let width: CGFloat

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(palette.bodyText)
            .frame(width: width, height: 48)
            .background(
                Capsule()
                    .stroke(palette.border.opacity(1.35), lineWidth: 1)
                    .background(Capsule().fill(palette.subtlePanel))
            )
    }
}

#Preview {
    GameOverOverlay(
        winner: .horizontal,
        stats: MatchStats(
            totalMoves: 18,
            horizontalMoves: 9,
            verticalMoves: 9,
            boardText: "10x10 · Diamond · 18% blockers",
            modeText: "Player vs AI · Hard"
        ),
        onUndo: {},
        onRematch: {},
        onChangeSetup: {}
    )
}

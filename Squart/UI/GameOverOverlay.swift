import SwiftUI

struct GameOverOverlay: View {
    let winner: Player
    let onUndo: (() -> Void)?
    let onRematch: () -> Void
    let onChangeSetup: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.42)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                VStack(spacing: 8) {
                    Text("Game Over")
                        .font(.system(size: 34, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.94))

                    Text("\(winner.displayName) wins")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color(red: 0.78, green: 0.66, blue: 0.52))

                    Text(resultLine)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.white.opacity(0.58))
                        .multilineTextAlignment(.center)
                }

                VStack(spacing: 10) {
                    if let onUndo {
                        Button(action: onUndo) {
                            OverlaySecondaryButtonLabel(title: "Undo", width: 286)
                        }
                        .buttonStyle(.plain)
                    }

                    HStack(spacing: 12) {
                        Button(action: onRematch) {
                            Text("Rematch")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(Color(red: 0.16, green: 0.12, blue: 0.09))
                                .frame(width: 132, height: 48)
                                .background(
                                    Capsule()
                                        .fill(Color(red: 0.78, green: 0.66, blue: 0.52))
                                        .shadow(color: Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.16), radius: 16)
                                )
                        }
                        .buttonStyle(.plain)

                        Button(action: onChangeSetup) {
                            OverlaySecondaryButtonLabel(title: "Change Setup", width: 142)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(28)
            .frame(maxWidth: 390)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(Color(red: 0.06, green: 0.055, blue: 0.05).opacity(0.72))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.22), lineWidth: 1)
                    )
            )
            .padding(24)
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

private struct OverlaySecondaryButtonLabel: View {
    let title: String
    let width: CGFloat

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white.opacity(0.86))
            .frame(width: width, height: 48)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    .background(Capsule().fill(Color.white.opacity(0.045)))
            )
    }
}

#Preview {
    GameOverOverlay(
        winner: .horizontal,
        onUndo: {},
        onRematch: {},
        onChangeSetup: {}
    )
}

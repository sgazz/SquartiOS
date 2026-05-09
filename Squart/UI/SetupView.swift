import SwiftUI

struct SetupView: View {
    private enum BoardSizeOption: Int, CaseIterable, Identifiable {
        case five = 5
        case eight = 8
        case ten = 10
        case twelve = 12

        var id: Int { rawValue }
        var title: String { "\(rawValue)x\(rawValue)" }
    }

    private enum BoardShapeOption: String, CaseIterable, Identifiable {
        case square = "Square"
        case diamond = "Diamond"

        var id: Self { self }

        func boardShape(size: Int) -> BoardShape {
            switch self {
            case .square:
                return .square(size: size)
            case .diamond:
                return .diamond(size: size)
            }
        }
    }

    private enum InactiveRatioOption: Double, CaseIterable, Identifiable {
        case none = 0
        case low = 0.10
        case standard = 0.18
        case high = 0.25

        var id: Double { rawValue }
        var title: String { "\(Int((rawValue * 100).rounded()))%" }
    }

    @State private var selectedGameMode: GameMode = .pvp
    @State private var selectedAIDifficulty: AIDifficulty = .easy
    @State private var selectedBoardShape: BoardShapeOption = .square
    @State private var selectedBoardSize: BoardSizeOption = .ten
    @State private var selectedInactiveRatio: InactiveRatioOption = .standard
    @State private var isShowingRules = false

    let onStartMatch: (GameConfiguration) -> Void
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            VStack(spacing: 8) {
                Text("Match Setup")
                    .font(.system(size: 34, weight: .semibold, design: .serif))
                    .foregroundStyle(.white.opacity(0.94))

                Text("Choose the shape of the contest.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white.opacity(0.58))
            }

            VStack(spacing: 18) {
                Picker("Game Mode", selection: $selectedGameMode) {
                    ForEach(GameMode.allCases) { mode in
                        Text(mode.rawValue).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(maxWidth: 320)

                if selectedGameMode == .playerVsAI {
                    Picker("AI Difficulty", selection: $selectedAIDifficulty) {
                        ForEach(AIDifficulty.allCases) { difficulty in
                            Text(difficulty.rawValue).tag(difficulty)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 220)
                    .transition(.opacity)
                }

                VStack(spacing: 12) {
                    Picker("Board Shape", selection: $selectedBoardShape) {
                        ForEach(BoardShapeOption.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 240)

                    Picker("Board Size", selection: $selectedBoardSize) {
                        ForEach(BoardSizeOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 340)

                    Picker("Inactive Cells", selection: $selectedInactiveRatio) {
                        ForEach(InactiveRatioOption.allCases) { option in
                            Text(option.title).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(maxWidth: 300)
                }
            }
            .tint(Color(red: 0.78, green: 0.66, blue: 0.52))

            Button {
                Haptics.selection()
                isShowingRules = true
            } label: {
                Text("How to Play")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(red: 0.78, green: 0.66, blue: 0.52))
                    .padding(.horizontal, 18)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .stroke(Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.32), lineWidth: 1)
                            .background(Capsule().fill(Color.white.opacity(0.035)))
                    )
            }
            .buttonStyle(.plain)

            HStack(spacing: 12) {
                Button(action: onBack) {
                    SetupSecondaryButtonLabel(title: "Back", width: 112)
                }
                .buttonStyle(.plain)

                Button {
                    Haptics.softImpact()
                    onStartMatch(
                        GameConfiguration(
                            mode: selectedGameMode,
                            aiDifficulty: selectedAIDifficulty,
                            boardShape: selectedBoardShape.boardShape(size: selectedBoardSize.rawValue),
                            boardSize: selectedBoardSize.rawValue,
                            inactiveCellRatio: selectedInactiveRatio.rawValue
                        )
                    )
                } label: {
                    Text("Start Match")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color(red: 0.16, green: 0.12, blue: 0.09))
                        .frame(width: 178, height: 52)
                        .background(
                            Capsule()
                                .fill(Color(red: 0.78, green: 0.66, blue: 0.52))
                                .shadow(color: Color(red: 0.78, green: 0.66, blue: 0.52).opacity(0.18), radius: 18)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(32)
        .sheet(isPresented: $isShowingRules) {
            RulesView()
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

private struct SetupSecondaryButtonLabel: View {
    let title: String
    let width: CGFloat

    var body: some View {
        Text(title)
            .font(.system(size: 16, weight: .medium))
            .foregroundStyle(.white.opacity(0.82))
            .frame(width: width, height: 52)
            .background(
                Capsule()
                    .stroke(Color.white.opacity(0.16), lineWidth: 1)
                    .background(Capsule().fill(Color.white.opacity(0.045)))
            )
    }
}

#Preview {
    SetupView { _ in } onBack: {}
        .background(Color.black)
}

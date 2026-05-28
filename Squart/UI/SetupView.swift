import SwiftUI

struct SetupView: View {
    private enum BoardSizeOption: Int, CaseIterable, Identifiable {
        case five = 5
        case eight = 8
        case ten = 10
        case twelve = 12

        var id: Int { rawValue }
        var title: String { "\(rawValue)x\(rawValue)" }

        init(configurationSize: Int) {
            self = Self(rawValue: configurationSize) ?? .ten
        }
    }

    private enum BoardShapeOption: String, CaseIterable, Identifiable {
        case square = "Square"
        case diamond = "Diamond"
        case circle = "Circle"
        case triangle = "Triangle"

        var id: Self { self }

        func boardShape(size: Int) -> BoardShape {
            switch self {
            case .square:
                return .square(size: size)
            case .diamond:
                return .diamond(size: size)
            case .circle:
                return .circle(diameter: size)
            case .triangle:
                return .triangle(size: size)
            }
        }

        init(configurationShape: BoardShape) {
            switch configurationShape {
            case .square:
                self = .square
            case .diamond:
                self = .diamond
            case .circle:
                self = .circle
            case .triangle:
                self = .triangle
            default:
                self = .square
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

        init(configurationRatio: Double) {
            self = Self.allCases.first { abs($0.rawValue - configurationRatio) < 0.001 } ?? .standard
        }
    }

    @State private var selectedGameMode: GameMode = .pvp
    @State private var selectedAIDifficulty: AIDifficulty = .easy
    @State private var selectedHumanPlayer: Player = .horizontal
    @State private var selectedTurnOrder: TurnOrder = .first
    @State private var selectedBoardShape: BoardShapeOption = .square
    @State private var selectedBoardSize: BoardSizeOption = .ten
    @State private var selectedInactiveRatio: InactiveRatioOption = .standard
    @State private var isShowingRules = false
    @Environment(\.squartPalette) private var palette
    private let configurationStore = GameConfigurationStore.shared

    let onStartMatch: (GameConfiguration) -> Void
    let onBack: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 22) {
                header

                VStack(spacing: 14) {
                    SetupSectionView(title: "Match", subtitle: "Choose the opponent rhythm.") {
                        VStack(spacing: 14) {
                            setupPicker("Game Mode") {
                                Picker("Game Mode", selection: $selectedGameMode) {
                                    ForEach(GameMode.allCases) { mode in
                                        Text(mode.rawValue).tag(mode)
                                    }
                                }
                                .squartSegmentedControlStyle(palette: palette)
                                .onChange(of: selectedGameMode) { _, _ in
                                    Haptics.selection()
                                }
                            }

                            if selectedGameMode == .playerVsAI {
                                setupPicker("AI Difficulty") {
                                    Picker("AI Difficulty", selection: $selectedAIDifficulty) {
                                        ForEach(AIDifficulty.allCases) { difficulty in
                                            Text(difficulty.rawValue).tag(difficulty)
                                        }
                                    }
                                    .squartSegmentedControlStyle(palette: palette)
                                    .onChange(of: selectedAIDifficulty) { _, _ in
                                        Haptics.selection()
                                    }
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))

                                setupPicker("Player Token") {
                                    Picker("Player Token", selection: $selectedHumanPlayer) {
                                        Text("Horizontal").tag(Player.horizontal)
                                        Text("Vertical").tag(Player.vertical)
                                    }
                                    .squartSegmentedControlStyle(palette: palette)
                                    .onChange(of: selectedHumanPlayer) { _, _ in
                                        Haptics.selection()
                                    }
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))

                                setupPicker("Turn Order") {
                                    Picker("Turn Order", selection: $selectedTurnOrder) {
                                        ForEach(TurnOrder.allCases) { turnOrder in
                                            Text(turnOrder.rawValue).tag(turnOrder)
                                        }
                                    }
                                    .squartSegmentedControlStyle(palette: palette)
                                    .onChange(of: selectedTurnOrder) { _, _ in
                                        Haptics.selection()
                                    }
                                }
                                .transition(.opacity.combined(with: .scale(scale: 0.985, anchor: .top)))
                            }
                        }
                    }

                    SetupSectionView(title: "Board", subtitle: "Tune the field before the first move.") {
                        VStack(spacing: 14) {
                            setupPicker("Shape") {
                                Picker("Board Shape", selection: $selectedBoardShape) {
                                    ForEach(BoardShapeOption.allCases) { option in
                                        Text(option.rawValue).tag(option)
                                    }
                                }
                                .squartSegmentedControlStyle(palette: palette)
                                .onChange(of: selectedBoardShape) { _, _ in
                                    Haptics.selection()
                                }
                            }

                            setupPicker("Size") {
                                Picker("Board Size", selection: $selectedBoardSize) {
                                    ForEach(BoardSizeOption.allCases) { option in
                                        Text(option.title).tag(option)
                                    }
                                }
                                .squartSegmentedControlStyle(palette: palette)
                                .onChange(of: selectedBoardSize) { _, _ in
                                    Haptics.selection()
                                }
                            }

                            setupPicker("Inactive") {
                                Picker("Inactive Cells", selection: $selectedInactiveRatio) {
                                    ForEach(InactiveRatioOption.allCases) { option in
                                        Text(option.title).tag(option)
                                    }
                                }
                                .squartSegmentedControlStyle(palette: palette)
                                .onChange(of: selectedInactiveRatio) { _, _ in
                                    Haptics.selection()
                                }
                            }
                        }
                    }
                }

                Button {
                    Haptics.selection()
                    isShowingRules = true
                } label: {
                    Label("How to Play", systemImage: "questionmark.circle")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(palette.accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .stroke(palette.accent.opacity(0.32), lineWidth: 1)
                                .background(Capsule().fill(palette.subtlePanel.opacity(0.78)))
                        )
                }
                .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.985, pressedOpacity: 0.88))

                HStack(spacing: 12) {
                    Button(action: onBack) {
                        Label("Back", systemImage: "chevron.left")
                    }
                        .buttonStyle(SquartSecondaryButtonStyle(width: 112))

                    Button {
                        Haptics.softImpact()
                        let configuration = selectedConfiguration
                        configurationStore.save(configuration)
                        onStartMatch(configuration)
                    } label: {
                        Text("Start Match")
                    }
                    .buttonStyle(SquartPrimaryButtonStyle())
                }
            }
            .frame(maxWidth: 460)
            .padding(.horizontal, 24)
            .padding(.vertical, 30)
        }
        .scrollIndicators(.hidden)
        .sheet(isPresented: $isShowingRules) {
            RulesView()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            apply(configurationStore.load())
        }
        .animation(SquartTheme.microInteractionAnimation, value: selectedGameMode)
        .animation(SquartTheme.microInteractionAnimation, value: selectedAIDifficulty)
        .animation(SquartTheme.microInteractionAnimation, value: selectedHumanPlayer)
        .animation(SquartTheme.microInteractionAnimation, value: selectedTurnOrder)
        .animation(SquartTheme.microInteractionAnimation, value: selectedBoardShape)
        .animation(SquartTheme.microInteractionAnimation, value: selectedBoardSize)
        .animation(SquartTheme.microInteractionAnimation, value: selectedInactiveRatio)
    }

    private var selectedConfiguration: GameConfiguration {
        GameConfiguration(
            mode: selectedGameMode,
            aiDifficulty: selectedAIDifficulty,
            humanPlayer: selectedHumanPlayer,
            humanTurnOrder: selectedTurnOrder,
            boardShape: selectedBoardShape.boardShape(size: selectedBoardSize.rawValue),
            boardSize: selectedBoardSize.rawValue,
            inactiveCellRatio: selectedInactiveRatio.rawValue
        )
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text("Match Setup")
                .font(SquartTheme.titleFont(size: 34))
                .foregroundStyle(palette.primaryText)

            Text("Shape the board before the first denial.")
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(palette.mutedText)
                .multilineTextAlignment(.center)
        }
    }

    private func setupPicker<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(palette.accent.opacity(0.86))

            content()
        }
    }

    private func apply(_ configuration: GameConfiguration) {
        selectedGameMode = configuration.mode
        selectedAIDifficulty = configuration.aiDifficulty
        selectedHumanPlayer = configuration.humanPlayer
        selectedTurnOrder = configuration.humanTurnOrder
        selectedBoardShape = BoardShapeOption(configurationShape: configuration.boardShape)
        selectedBoardSize = BoardSizeOption(configurationSize: configuration.boardSize)
        selectedInactiveRatio = InactiveRatioOption(configurationRatio: configuration.inactiveCellRatio)
    }
}

private extension View {
    func squartSegmentedControlStyle(palette: SquartThemePalette) -> some View {
        self
            .pickerStyle(.segmented)
            .tint(palette.segmentedSelectedBackground)
            .environment(\.colorScheme, palette.segmentedColorScheme)
            .padding(5)
            .background(
                Capsule()
                    .fill(palette.segmentedBackground)
                    .overlay(Capsule().stroke(palette.controlBorder, lineWidth: 1))
            )
    }
}

#Preview {
    SetupView { _ in } onBack: {}
        .background(SquartVisualTheme.defaultTheme.palette.backgroundBottom)
}

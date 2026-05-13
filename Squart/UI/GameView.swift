import SwiftUI

struct GameView: View {
    @State private var game: SquartGame
    @State private var boardMode: GameBoardMode = .classic
    @State private var previewPosition: BoardPosition?
    @State private var resetCameraToken = 0
    @State private var rotateLeftToken = 0
    @State private var rotateRightToken = 0
    @State private var isAITurnPending = false
    @State private var aiTurnToken = 0
    @State private var lastMovePositions: Set<BoardPosition> = []
    @State private var moveAnimationToken = 0
    @State private var isPlacementInputLocked = false
    @State private var didTriggerGameOverHaptic = false
    @State private var moveCount = 0
    @State private var horizontalMoveCount = 0
    @State private var verticalMoveCount = 0
    @State private var aiPreviewPositions: Set<BoardPosition> = []
    @State private var isDailyChallengeCompleted = false
    @State private var show2DMoveHints = false
    @State private var moveHintTimerToken = 0
    @State private var appliedMovePlayers: [Player] = []

    let configuration: GameConfiguration
    let dailyChallenge: DailyChallenge?
    let onChangeSetup: () -> Void
    let onDailyChallengeCompleted: () -> Void
    private let screenshotConfiguration: ScreenshotConfiguration.GamePreset?
    private let ai = SquartAI()
    private let dailyCompletionStore: DailyChallengeHistoryStore

    init(
        configuration: GameConfiguration = GameConfiguration(),
        dailyChallenge: DailyChallenge? = nil,
        dailyCompletionStore: DailyChallengeHistoryStore = .shared,
        onChangeSetup: @escaping () -> Void = {},
        onDailyChallengeCompleted: @escaping () -> Void = {},
        screenshotConfiguration: ScreenshotConfiguration.GamePreset? = nil
    ) {
        self.configuration = configuration
        self.dailyChallenge = dailyChallenge
        self.dailyCompletionStore = dailyCompletionStore
        self.onChangeSetup = onChangeSetup
        self.onDailyChallengeCompleted = onDailyChallengeCompleted
        self.screenshotConfiguration = screenshotConfiguration
        self._isDailyChallengeCompleted = State(
            initialValue: (screenshotConfiguration?.isDailyCompleted ?? false) || (dailyChallenge.map { dailyCompletionStore.isCompleted(dateKey: $0.dateKey) } ?? false)
        )
        if let screenshotConfiguration {
            let bootstrap = Self.bootstrapState(for: screenshotConfiguration)
            self._game = State(initialValue: bootstrap.game)
            self._boardMode = State(initialValue: screenshotConfiguration.boardMode)
            self._isAITurnPending = State(initialValue: screenshotConfiguration.showsAITurnPending)
            self._moveCount = State(initialValue: bootstrap.moveCount)
            self._horizontalMoveCount = State(initialValue: bootstrap.horizontalMoveCount)
            self._verticalMoveCount = State(initialValue: bootstrap.verticalMoveCount)
            self._lastMovePositions = State(initialValue: bootstrap.lastMovePositions)
            self._appliedMovePlayers = State(initialValue: bootstrap.appliedMovePlayers)
            self._previewPosition = State(initialValue: screenshotConfiguration.previewOrigin)
            self._aiPreviewPositions = State(initialValue: screenshotConfiguration.aiPreviewPositions)
            self._isPlacementInputLocked = State(initialValue: screenshotConfiguration.lockInput)
            self._didTriggerGameOverHaptic = State(initialValue: screenshotConfiguration.showsGameOverOverlay)
        } else {
            self._game = State(initialValue: Self.newGame(configuration: configuration))
        }
    }

    var body: some View {
        ZStack {
            GameBackground()
                .ignoresSafeArea()

            VStack(spacing: 8) {
                GameHUDView(
                    configuration: configuration,
                    currentPlayer: game.currentPlayer,
                    isAITurnPending: isAITurnPending,
                    moveCount: moveCount,
                    canUndo: game.canUndo,
                    boardMode: $boardMode,
                    onUndoLastMove: undoLastMove,
                    onResetGame: resetGame,
                    onResetCamera: resetCamera,
                    onRotateBoardLeft: rotateBoardLeft,
                    onRotateBoardRight: rotateBoardRight,
                    onChangeSetup: changeSetup
                )

                if let dailyChallenge {
                    DailyChallengeBanner(
                        challenge: dailyChallenge,
                        isCompleted: isDailyChallengeCompleted
                    )
                        .padding(.horizontal, 12)
                }

                GeometryReader { proxy in
                    boardContent(in: proxy.size)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: game.isFinished) { _, isFinished in
                if isFinished {
                    clear2DMoveHints()
                }

                guard isFinished, game.winner != nil, !didTriggerGameOverHaptic else {
                    return
                }

                didTriggerGameOverHaptic = true
                Haptics.softImpact()
                SoundEffects.playGameOver()
                recordDailyCompletionIfNeeded(winner: game.winner)
            }
            .onChange(of: boardMode) { _, mode in
                if mode == .classic {
                    restart2DMoveHintTimer()
                } else {
                    clear2DMoveHints()
                }
            }
            .task {
                if screenshotConfiguration?.showsGameOverOverlay == true {
                    didTriggerGameOverHaptic = true
                }
                restart2DMoveHintTimer()
                scheduleAIMoveIfNeeded()
            }

            if let winner = game.winner {
                GameOverOverlay(
                    winner: winner,
                    stats: matchStats,
                    onUndo: game.canUndo ? { undoLastMove() } : nil,
                    onRematch: rematch,
                    onChangeSetup: changeSetup
                )
                .transition(.opacity)
            }
        }
    }

    @ViewBuilder
    private func boardContent(in size: CGSize) -> some View {
        switch boardMode {
        case .classic:
            let side = max(0, min(size.width - 28, size.height))

            ClassicBoardView(
                board: game.board,
                currentPlayer: game.currentPlayer,
                showMoveHints: show2DMoveHints,
                isFinished: game.isFinished
            ) { position in
                previewPosition = nil
                playHumanMove(at: position)
            }
            .frame(width: side, height: side)
            .frame(width: size.width, height: size.height, alignment: .top)

        case .board3D:
            SquartSceneView(
                board: game.board,
                previewPositions: previewPositions,
                aiPreviewPositions: aiPreviewPositions,
                lastMovePositions: lastMovePositions,
                moveAnimationToken: moveAnimationToken,
                resetCameraToken: resetCameraToken,
                rotateLeftToken: rotateLeftToken,
                rotateRightToken: rotateRightToken
            ) { position in
                handle3DTileTap(at: position)
            }
            .frame(width: size.width, height: size.height)
            .clipped()
        }
    }

    private var previewPositions: Set<BoardPosition> {
        guard let previewPosition else {
            return []
        }

        return Set(Move(player: game.currentPlayer, origin: previewPosition).occupiedPositions)
    }

    private var matchStats: MatchStats {
        MatchStats(
            totalMoves: moveCount,
            horizontalMoves: horizontalMoveCount,
            verticalMoves: verticalMoveCount,
            boardText: boardStatsText,
            modeText: modeStatsText
        )
    }

    @discardableResult
    private func playMove(at position: BoardPosition) -> Bool {
        let move = Move(player: game.currentPlayer, origin: position)

        if game.play(move) {
            recordAppliedMove(move)
            return true
        }

        return false
    }

    private func playHumanMove(at position: BoardPosition) {
        guard canHumanMove else {
            return
        }

        if playMove(at: position) {
            previewPosition = nil
            scheduleAIMoveIfNeeded()
        } else {
            Haptics.warning()
            SoundEffects.playInvalid()
        }
    }

    private func handle3DTileTap(at position: BoardPosition) {
        guard canHumanMove else {
            return
        }

        let move = Move(player: game.currentPlayer, origin: position)

        guard game.board.isValidMove(move) else {
            previewPosition = nil
            Haptics.warning()
            SoundEffects.playInvalid()
            return
        }

        if previewPosition == position {
            if playMove(move) {
                lockPlacementInputBriefly()
                scheduleAIMoveIfNeeded()
            } else {
                Haptics.warning()
                SoundEffects.playInvalid()
            }
            previewPosition = nil
        } else {
            previewPosition = position
            Haptics.selection()
        }
    }

    private func resetGame() {
        Haptics.softImpact()
        resetMatchState()
    }

    private func undoLastMove() {
        guard game.canUndo else {
            return
        }

        let wasAITurnPending = isAITurnPending

        aiTurnToken += 1
        isAITurnPending = false
        isPlacementInputLocked = false

        let undoLimit = configuration.mode == .playerVsAI ? 2 : 1
        let targetUndoCount = wasAITurnPending ? 1 : undoLimit
        var undoneCount = 0

        for _ in 0..<targetUndoCount where game.undoLastMove() {
            undoneCount += 1
        }

        guard undoneCount > 0 else {
            return
        }

        moveCount = max(0, moveCount - undoneCount)
        rebalanceMoveCountsAfterUndo(undoneCount)
        previewPosition = nil
        lastMovePositions = []
        aiPreviewPositions = []
        moveAnimationToken += 1
        didTriggerGameOverHaptic = false
        Haptics.lightImpact()
        restart2DMoveHintTimer()
        scheduleAIMoveIfNeeded()
    }

    private func rematch() {
        Haptics.softImpact()
        resetMatchState()
    }

    private func changeSetup() {
        Haptics.softImpact()
        onChangeSetup()
    }

    private func resetCamera() {
        Haptics.selection()
        resetCameraToken += 1
    }

    private func rotateBoardLeft() {
        Haptics.selection()
        rotateLeftToken += 1
    }

    private func rotateBoardRight() {
        Haptics.selection()
        rotateRightToken += 1
    }

    private func resetMatchState() {
        aiTurnToken += 1
        isAITurnPending = false
        isPlacementInputLocked = false
        game = Self.newGame(configuration: configuration)
        lastMovePositions = []
        previewPosition = nil
        aiPreviewPositions = []
        didTriggerGameOverHaptic = false
        moveCount = 0
        horizontalMoveCount = 0
        verticalMoveCount = 0
        appliedMovePlayers = []
        clear2DMoveHints()
        if let dailyChallenge {
            isDailyChallengeCompleted = dailyCompletionStore.isCompleted(dateKey: dailyChallenge.dateKey)
        }
        restart2DMoveHintTimer()
        scheduleAIMoveIfNeeded()
    }

    private var canHumanMove: Bool {
        guard !game.isFinished, game.winner == nil, !isAITurnPending, !isPlacementInputLocked else {
            return false
        }

        switch configuration.mode {
        case .pvp:
            return true
        case .playerVsAI:
            return game.currentPlayer == humanPlayer
        }
    }

    private func scheduleAIMoveIfNeeded() {
        guard
            configuration.mode == .playerVsAI,
            !game.isFinished,
            game.currentPlayer == aiPlayer
        else {
            return
        }

        previewPosition = nil
        aiPreviewPositions = []
        clear2DMoveHints()
        isAITurnPending = true
        aiTurnToken += 1
        let activeToken = aiTurnToken

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: configuration.aiDifficulty.thinkingDelayNanoseconds)

            guard activeToken == aiTurnToken, isAITurnPending else {
                return
            }

            if let move = ai.move(
                for: aiPlayer,
                opponent: humanPlayer,
                on: game.board,
                difficulty: configuration.aiDifficulty
            ) {
                if boardMode == .board3D {
                    aiPreviewPositions = Set(move.occupiedPositions)
                    try? await Task.sleep(nanoseconds: 250_000_000)

                    guard activeToken == aiTurnToken, isAITurnPending else {
                        aiPreviewPositions = []
                        return
                    }
                }

                _ = playMove(move)
            }

            isAITurnPending = false
            previewPosition = nil
            aiPreviewPositions = []
            restart2DMoveHintTimer()
        }
    }

    @discardableResult
    private func playMove(_ move: Move) -> Bool {
        if game.play(move) {
            recordAppliedMove(move)
            return true
        }

        return false
    }

    private func recordAppliedMove(_ move: Move) {
        lastMovePositions = Set(move.occupiedPositions)
        moveAnimationToken += 1
        moveCount += 1
        appliedMovePlayers.append(move.player)
        incrementMoveCount(for: move.player)
        Haptics.lightImpact()
        SoundEffects.playMove()
        restart2DMoveHintTimer()
    }

    private func incrementMoveCount(for player: Player) {
        switch player {
        case .horizontal:
            horizontalMoveCount += 1
        case .vertical:
            verticalMoveCount += 1
        }
    }

    private func rebalanceMoveCountsAfterUndo(_ undoCount: Int) {
        guard undoCount > 0 else {
            return
        }

        let removedPlayers = appliedMovePlayers.suffix(undoCount)
        appliedMovePlayers.removeLast(min(undoCount, appliedMovePlayers.count))

        for player in removedPlayers {
            decrementMoveCount(for: player)
        }
    }

    private func decrementMoveCount(for player: Player) {
        switch player {
        case .horizontal:
            horizontalMoveCount = max(0, horizontalMoveCount - 1)
        case .vertical:
            verticalMoveCount = max(0, verticalMoveCount - 1)
        }
    }

    private func lockPlacementInputBriefly() {
        isPlacementInputLocked = true
        let activeAnimationToken = moveAnimationToken

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 260_000_000)

            guard activeAnimationToken == moveAnimationToken else {
                return
            }

            isPlacementInputLocked = false
        }
    }

    private static func newGame(configuration: GameConfiguration) -> SquartGame {
        SquartGame(
            board: BoardGenerator.board(for: configuration),
            startingPlayer: configuration.startingPlayer
        )
    }

    private static func bootstrapState(
        for preset: ScreenshotConfiguration.GamePreset
    ) -> (
        game: SquartGame,
        moveCount: Int,
        horizontalMoveCount: Int,
        verticalMoveCount: Int,
        lastMovePositions: Set<BoardPosition>,
        appliedMovePlayers: [Player]
    ) {
        var game = Self.newGame(configuration: preset.configuration)
        var appliedMovePlayers: [Player] = []
        var lastMovePositions: Set<BoardPosition> = []
        var horizontalMoveCount = 0
        var verticalMoveCount = 0

        for _ in 0..<preset.appliedPlies {
            guard let move = game.validMovesForCurrentPlayer().first else {
                break
            }

            guard game.play(move) else {
                break
            }

            appliedMovePlayers.append(move.player)
            lastMovePositions = Set(move.occupiedPositions)
            if move.player == .horizontal {
                horizontalMoveCount += 1
            } else {
                verticalMoveCount += 1
            }
        }

        return (
            game: game,
            moveCount: appliedMovePlayers.count,
            horizontalMoveCount: horizontalMoveCount,
            verticalMoveCount: verticalMoveCount,
            lastMovePositions: lastMovePositions,
            appliedMovePlayers: appliedMovePlayers
        )
    }

    private func recordDailyCompletionIfNeeded(winner: Player?) {
        guard
            let dailyChallenge,
            winner == humanPlayer,
            !isDailyChallengeCompleted
        else {
            return
        }

        if dailyCompletionStore.markCompleted(dateKey: dailyChallenge.dateKey) {
            isDailyChallengeCompleted = true
            onDailyChallengeCompleted()
        }
    }

    private var shouldShowHintsAfterDelay: Bool {
        guard boardMode == .classic else { return false }
        guard !game.isFinished, game.winner == nil else { return false }
        guard !isPlacementInputLocked else { return false }
        guard !isAITurnPending else { return false }

        switch configuration.mode {
        case .pvp:
            return true
        case .playerVsAI:
            return game.currentPlayer == humanPlayer
        }
    }

    private var humanPlayer: Player {
        configuration.humanPlayer
    }

    private var aiPlayer: Player {
        configuration.aiPlayer
    }

    private func restart2DMoveHintTimer() {
        moveHintTimerToken += 1
        show2DMoveHints = false
        let currentToken = moveHintTimerToken

        guard shouldShowHintsAfterDelay else {
            return
        }

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 5_000_000_000)
            guard currentToken == moveHintTimerToken else { return }
            guard shouldShowHintsAfterDelay else { return }
            show2DMoveHints = true
        }
    }

    private func clear2DMoveHints() {
        moveHintTimerToken += 1
        show2DMoveHints = false
    }
}

private extension GameView {
    var boardStatsText: String {
        let size = "\(configuration.boardSize)x\(configuration.boardSize)"
        let inactive = "\(Int((configuration.inactiveCellRatio * 100).rounded()))% blockers"
        return "\(size) · \(boardShapeName) · \(inactive)"
    }

    var modeStatsText: String {
        switch configuration.mode {
        case .pvp:
            return GameMode.pvp.rawValue
        case .playerVsAI:
            return "\(GameMode.playerVsAI.rawValue) · \(configuration.aiDifficulty.rawValue)"
        }
    }

    var boardShapeName: String {
        switch configuration.boardShape {
        case .square:
            return "Square"
        case .diamond:
            return "Diamond"
        case .circle:
            return "Circle"
        case .triangle:
            return "Triangle"
        case .rectangle:
            return "Rectangle"
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

private extension AIDifficulty {
    var thinkingDelayNanoseconds: UInt64 {
        switch self {
        case .easy:
            return 350_000_000
        case .medium:
            return 550_000_000
        case .hard:
            return 750_000_000
        }
    }
}

private struct GameBackground: View {
    @Environment(\.squartPalette) private var palette

    var body: some View {
        palette.appBackground
    }
}

private struct DailyChallengeBanner: View {
    @Environment(\.squartPalette) private var palette
    let challenge: DailyChallenge
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "calendar")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(palette.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(isCompleted ? "Completed Today" : challenge.title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.strongText)

                Text(isCompleted ? "Daily win recorded locally" : challenge.roleSummary)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(palette.mutedText)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .squartCard(cornerRadius: 14, fill: palette.panel.opacity(0.72), stroke: palette.border)
    }
}

#Preview {
    GameView()
}

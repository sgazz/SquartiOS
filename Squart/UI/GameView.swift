import SwiftUI

struct GameView: View {
    @State private var game: SquartGame
    @State private var boardMode: GameBoardMode = .debug2D
    @State private var previewPosition: BoardPosition?
    @State private var resetCameraToken = 0
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

    let configuration: GameConfiguration
    let onChangeSetup: () -> Void
    private let ai = SquartAI()

    init(
        configuration: GameConfiguration = GameConfiguration(),
        onChangeSetup: @escaping () -> Void = {}
    ) {
        self.configuration = configuration
        self.onChangeSetup = onChangeSetup
        self._game = State(initialValue: Self.newGame(configuration: configuration))
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
                    onChangeSetup: changeSetup
                )

                GeometryReader { proxy in
                    boardContent(in: proxy.size)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onChange(of: game.isFinished) { _, isFinished in
                guard isFinished, game.winner != nil, !didTriggerGameOverHaptic else {
                    return
                }

                didTriggerGameOverHaptic = true
                Haptics.softImpact()
                SoundEffects.playGameOver()
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
        case .debug2D:
            let side = max(0, min(size.width - 28, size.height))

            BoardDebugView(
                board: game.board,
                currentPlayer: game.currentPlayer,
                isFinished: game.isFinished
            ) { position in
                previewPosition = nil
                playHumanMove(at: position)
            }
            .frame(width: side, height: side)
            .frame(width: size.width, height: size.height, alignment: .top)

        case .preview3D:
            SquartSceneView(
                board: game.board,
                previewPositions: previewPositions,
                aiPreviewPositions: aiPreviewPositions,
                lastMovePositions: lastMovePositions,
                moveAnimationToken: moveAnimationToken,
                resetCameraToken: resetCameraToken
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
    }

    private var canHumanMove: Bool {
        guard !game.isFinished, game.winner == nil, !isAITurnPending, !isPlacementInputLocked else {
            return false
        }

        switch configuration.mode {
        case .pvp:
            return true
        case .playerVsAI:
            return game.currentPlayer == .horizontal
        }
    }

    private func scheduleAIMoveIfNeeded() {
        guard
            configuration.mode == .playerVsAI,
            !game.isFinished,
            game.currentPlayer == .vertical
        else {
            return
        }

        previewPosition = nil
        aiPreviewPositions = []
        isAITurnPending = true
        aiTurnToken += 1
        let activeToken = aiTurnToken

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: configuration.aiDifficulty.thinkingDelayNanoseconds)

            guard activeToken == aiTurnToken, isAITurnPending else {
                return
            }

            if let move = ai.move(
                for: .vertical,
                opponent: .horizontal,
                on: game.board,
                difficulty: configuration.aiDifficulty
            ) {
                if boardMode == .preview3D {
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
        incrementMoveCount(for: move.player)
        Haptics.lightImpact()
        SoundEffects.playMove()
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

        switch configuration.mode {
        case .pvp:
            decrementMoveCount(for: game.currentPlayer)
        case .playerVsAI:
            if undoCount == 1 {
                decrementMoveCount(for: .horizontal)
            } else {
                decrementMoveCount(for: .vertical)
                decrementMoveCount(for: .horizontal)
            }
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
            board: BoardGenerator.board(for: configuration)
        )
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
    var body: some View {
        LinearGradient(
            colors: [
                SquartTheme.Colors.backgroundTop,
                SquartTheme.Colors.backgroundMid,
                SquartTheme.Colors.backgroundBottom
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    GameView()
}

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
            VStack(spacing: 16) {
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

                Group {
                    switch boardMode {
                    case .debug2D:
                        BoardDebugView(
                            board: game.board,
                            currentPlayer: game.currentPlayer,
                            isFinished: game.isFinished
                        ) { position in
                            previewPosition = nil
                            playHumanMove(at: position)
                        }
                    case .preview3D:
                        SquartSceneView(
                            board: game.board,
                            previewPositions: previewPositions,
                            lastMovePositions: lastMovePositions,
                            moveAnimationToken: moveAnimationToken,
                            resetCameraToken: resetCameraToken
                        ) { position in
                            handle3DTileTap(at: position)
                        }
                            .aspectRatio(1, contentMode: .fit)
                            .frame(maxWidth: 620)
                    }
                }
                .padding(.horizontal, 20)
            }
            .padding(.vertical, 18)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(GameBackground())
            .ignoresSafeArea()
            .onChange(of: game.isFinished) { _, isFinished in
                guard isFinished, game.winner != nil, !didTriggerGameOverHaptic else {
                    return
                }

                didTriggerGameOverHaptic = true
                Haptics.softImpact()
            }

            if let winner = game.winner {
                GameOverOverlay(
                    winner: winner,
                    onUndo: game.canUndo ? { undoLastMove() } : nil,
                    onRematch: rematch,
                    onChangeSetup: changeSetup
                )
                .transition(.opacity)
            }
        }
    }

    private var previewPositions: Set<BoardPosition> {
        guard let previewPosition else {
            return []
        }

        return Set(Move(player: game.currentPlayer, origin: previewPosition).occupiedPositions)
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
            return
        }

        if previewPosition == position {
            if playMove(move) {
                lockPlacementInputBriefly()
                scheduleAIMoveIfNeeded()
            } else {
                Haptics.warning()
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
        previewPosition = nil
        lastMovePositions = []
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
        didTriggerGameOverHaptic = false
        moveCount = 0
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
        isAITurnPending = true
        aiTurnToken += 1
        let activeToken = aiTurnToken

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 550_000_000)

            guard activeToken == aiTurnToken, isAITurnPending else {
                return
            }

            if let move = ai.move(
                for: .vertical,
                opponent: .horizontal,
                on: game.board,
                difficulty: configuration.aiDifficulty
            ) {
                _ = playMove(move)
            }

            isAITurnPending = false
            previewPosition = nil
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
        Haptics.lightImpact()
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

private struct GameBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.06, green: 0.06, blue: 0.06),
                Color(red: 0.11, green: 0.10, blue: 0.09),
                Color(red: 0.04, green: 0.04, blue: 0.04)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

#Preview {
    GameView()
}

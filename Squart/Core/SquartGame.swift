nonisolated struct SquartGame: Equatable, Sendable {
    private(set) var board: SquartBoard
    private(set) var currentPlayer: Player
    private(set) var winner: Player?
    private(set) var placedMoves: [Move] = []
    private var history: [GameSnapshot] = []

    init(board: SquartBoard, startingPlayer: Player = .horizontal) {
        self.board = board
        self.currentPlayer = startingPlayer
    }

    var isFinished: Bool {
        winner != nil || !board.hasValidMove(for: currentPlayer)
    }

    func validMovesForCurrentPlayer() -> [Move] {
        board.validMoves(for: currentPlayer)
    }

    var canUndo: Bool {
        !history.isEmpty
    }

    mutating func play(_ move: Move) -> Bool {
        guard winner == nil, move.player == currentPlayer else {
            return false
        }

        let previousState = snapshot

        guard board.apply(move) else {
            return false
        }

        history.append(previousState)
        placedMoves.append(move)

        let nextPlayer = currentPlayer.opponent

        if board.hasValidMove(for: nextPlayer) {
            currentPlayer = nextPlayer
        } else {
            winner = currentPlayer
        }

        return true
    }

    @discardableResult
    mutating func undoLastMove() -> Bool {
        guard let previousState = history.popLast() else {
            return false
        }

        board = previousState.board
        currentPlayer = previousState.currentPlayer
        winner = previousState.winner
        placedMoves = previousState.placedMoves
        return true
    }

    private var snapshot: GameSnapshot {
        GameSnapshot(
            board: board,
            currentPlayer: currentPlayer,
            winner: winner,
            placedMoves: placedMoves
        )
    }
}

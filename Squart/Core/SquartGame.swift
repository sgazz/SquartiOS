nonisolated struct SquartGame: Equatable, Sendable {
    private(set) var board: SquartBoard
    private(set) var currentPlayer: Player
    private(set) var winner: Player?

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

    mutating func play(_ move: Move) -> Bool {
        guard winner == nil, move.player == currentPlayer, board.apply(move) else {
            return false
        }

        let nextPlayer = currentPlayer.opponent

        if board.hasValidMove(for: nextPlayer) {
            currentPlayer = nextPlayer
        } else {
            winner = currentPlayer
        }

        return true
    }
}

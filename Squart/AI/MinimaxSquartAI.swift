nonisolated struct MinimaxSquartAI: Sendable {
    private let terminalScore = 10_000

    init() {}

    func move(for player: Player, opponent: Player, on board: SquartBoard) -> Move? {
        let validMoves = board.validMoves(for: player)
        guard !validMoves.isEmpty else {
            return nil
        }

        let depth = searchDepth(for: board)
        var alpha = Int.min
        let beta = Int.max
        var bestScore = Int.min
        var bestMoves: [Move] = []

        for move in orderedMoves(validMoves, for: player, opponent: opponent, on: board) {
            var simulatedBoard = board
            _ = simulatedBoard.apply(move)

            let score = minimax(
                board: simulatedBoard,
                currentPlayer: opponent,
                aiPlayer: player,
                humanPlayer: opponent,
                depthRemaining: depth - 1,
                alpha: alpha,
                beta: beta
            )

            if score > bestScore {
                bestScore = score
                bestMoves = [move]
            } else if score == bestScore {
                bestMoves.append(move)
            }

            alpha = max(alpha, bestScore)
        }

        return bestMoves.randomElement()
    }

    private func minimax(
        board: SquartBoard,
        currentPlayer: Player,
        aiPlayer: Player,
        humanPlayer: Player,
        depthRemaining: Int,
        alpha: Int,
        beta: Int
    ) -> Int {
        let moves = board.validMoves(for: currentPlayer)

        guard !moves.isEmpty else {
            return currentPlayer == aiPlayer ? -terminalScore - depthRemaining : terminalScore + depthRemaining
        }

        guard depthRemaining > 0 else {
            return evaluate(board: board, aiPlayer: aiPlayer, humanPlayer: humanPlayer)
        }

        if currentPlayer == aiPlayer {
            var bestScore = Int.min
            var alpha = alpha

            for move in orderedMoves(moves, for: aiPlayer, opponent: humanPlayer, on: board) {
                var simulatedBoard = board
                _ = simulatedBoard.apply(move)

                let score = minimax(
                    board: simulatedBoard,
                    currentPlayer: humanPlayer,
                    aiPlayer: aiPlayer,
                    humanPlayer: humanPlayer,
                    depthRemaining: depthRemaining - 1,
                    alpha: alpha,
                    beta: beta
                )

                bestScore = max(bestScore, score)
                alpha = max(alpha, bestScore)

                if alpha >= beta {
                    break
                }
            }

            return bestScore
        } else {
            var bestScore = Int.max
            var beta = beta

            for move in orderedMoves(moves, for: humanPlayer, opponent: aiPlayer, on: board) {
                var simulatedBoard = board
                _ = simulatedBoard.apply(move)

                let score = minimax(
                    board: simulatedBoard,
                    currentPlayer: aiPlayer,
                    aiPlayer: aiPlayer,
                    humanPlayer: humanPlayer,
                    depthRemaining: depthRemaining - 1,
                    alpha: alpha,
                    beta: beta
                )

                bestScore = min(bestScore, score)
                beta = min(beta, bestScore)

                if alpha >= beta {
                    break
                }
            }

            return bestScore
        }
    }

    private func evaluate(board: SquartBoard, aiPlayer: Player, humanPlayer: Player) -> Int {
        let aiMoves = board.validMoves(for: aiPlayer).count
        let humanMoves = board.validMoves(for: humanPlayer).count

        if aiMoves == 0 {
            return -terminalScore
        }

        if humanMoves == 0 {
            return terminalScore
        }

        return aiMoves * 8 - humanMoves * 10
    }

    private func orderedMoves(
        _ moves: [Move],
        for player: Player,
        opponent: Player,
        on board: SquartBoard
    ) -> [Move] {
        moves
            .map { move in
                (move: move, score: scoreAfter(move, for: player, opponent: opponent, on: board))
            }
            .sorted { first, second in
                first.score > second.score
            }
            .map(\.move)
    }

    private func scoreAfter(_ move: Move, for player: Player, opponent: Player, on board: SquartBoard) -> Int {
        var simulatedBoard = board
        _ = simulatedBoard.apply(move)
        return simulatedBoard.validMoves(for: player).count - simulatedBoard.validMoves(for: opponent).count
    }

    private func searchDepth(for board: SquartBoard) -> Int {
        board.rows * board.columns <= 25 ? 3 : 2
    }
}

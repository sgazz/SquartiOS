nonisolated struct GreedySquartAI: Sendable {
    init() {}

    func move(for player: Player, opponent: Player, on board: SquartBoard) -> Move? {
        let validMoves = board.validMoves(for: player)
        var bestScore = Int.min
        var bestMoves: [Move] = []

        for move in validMoves {
            var simulatedBoard = board
            _ = simulatedBoard.apply(move)

            let aiMobility = simulatedBoard.validMoves(for: player).count
            let opponentMobility = simulatedBoard.validMoves(for: opponent).count
            let score = aiMobility - opponentMobility

            if score > bestScore {
                bestScore = score
                bestMoves = [move]
            } else if score == bestScore {
                bestMoves.append(move)
            }
        }

        return bestMoves.randomElement()
    }
}

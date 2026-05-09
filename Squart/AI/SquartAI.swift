nonisolated struct SquartAI: Sendable {
    private let randomAI = RandomSquartAI()
    private let greedyAI = GreedySquartAI()

    init() {}

    func move(
        for player: Player,
        opponent: Player,
        on board: SquartBoard,
        difficulty: AIDifficulty
    ) -> Move? {
        switch difficulty {
        case .easy:
            return randomAI.move(for: player, on: board)
        case .medium:
            return greedyAI.move(for: player, opponent: opponent, on: board)
        }
    }
}

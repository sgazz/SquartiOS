nonisolated struct RandomSquartAI: Sendable {
    init() {}

    func move(for player: Player, on board: SquartBoard) -> Move? {
        board.validMoves(for: player).randomElement()
    }
}

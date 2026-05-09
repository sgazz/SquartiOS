nonisolated struct GameConfiguration: Equatable, Sendable {
    static let standard = GameConfiguration()

    let mode: GameMode
    let aiDifficulty: AIDifficulty
    let boardShape: BoardShape
    let boardSize: Int
    let inactiveCellRatio: Double

    init(
        mode: GameMode = .pvp,
        aiDifficulty: AIDifficulty = .easy,
        boardShape: BoardShape? = nil,
        boardSize: Int = 10,
        inactiveCellRatio: Double = 0.18
    ) {
        let sanitizedBoardSize = max(2, boardSize)

        self.mode = mode
        self.aiDifficulty = aiDifficulty
        self.boardSize = sanitizedBoardSize
        self.boardShape = boardShape ?? .square(size: sanitizedBoardSize)
        self.inactiveCellRatio = min(max(inactiveCellRatio, 0), 0.75)
    }
}

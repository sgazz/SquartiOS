nonisolated struct GameSnapshot: Equatable, Sendable {
    let board: SquartBoard
    let currentPlayer: Player
    let winner: Player?
    let placedMoves: [Move]
}

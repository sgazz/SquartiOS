nonisolated struct Move: Equatable, Codable, Sendable {
    let player: Player
    let origin: BoardPosition

    init(player: Player, origin: BoardPosition) {
        self.player = player
        self.origin = origin
    }

    var occupiedPositions: [BoardPosition] {
        let delta = player.moveDelta
        return [
            origin,
            origin.offsetBy(rows: delta.rows, columns: delta.columns)
        ]
    }
}

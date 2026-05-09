nonisolated struct SquartBoard: Equatable, Sendable {
    let rows: Int
    let columns: Int

    private var cells: [CellState]

    init(
        rows: Int,
        columns: Int,
        inactiveCells: Set<BoardPosition> = [],
        outsideCells: Set<BoardPosition> = []
    ) {
        precondition(rows > 0, "Board rows must be greater than zero.")
        precondition(columns > 0, "Board columns must be greater than zero.")

        self.rows = rows
        self.columns = columns
        self.cells = (0..<(rows * columns)).map { index in
            let position = BoardPosition(row: index / columns, column: index % columns)

            if outsideCells.contains(position) {
                return .outside
            }

            if inactiveCells.contains(position) {
                return .inactive
            }

            return .empty
        }
    }

    // MARK: - Cell Access

    func contains(_ position: BoardPosition) -> Bool {
        position.row >= 0 &&
            position.row < rows &&
            position.column >= 0 &&
            position.column < columns
    }

    func cellState(at position: BoardPosition) -> CellState? {
        guard contains(position) else {
            return nil
        }

        return cells[index(for: position)]
    }

    func isActiveEmptyCell(at position: BoardPosition) -> Bool {
        cellState(at: position) == .empty
    }

    // MARK: - Moves

    func isValidMove(_ move: Move) -> Bool {
        move.occupiedPositions.allSatisfy(isActiveEmptyCell)
    }

    func validMoves(for player: Player) -> [Move] {
        var moves: [Move] = []

        for row in 0..<rows {
            for column in 0..<columns {
                let move = Move(player: player, origin: BoardPosition(row: row, column: column))

                if isValidMove(move) {
                    moves.append(move)
                }
            }
        }

        return moves
    }

    func hasValidMove(for player: Player) -> Bool {
        for row in 0..<rows {
            for column in 0..<columns {
                let move = Move(player: player, origin: BoardPosition(row: row, column: column))

                if isValidMove(move) {
                    return true
                }
            }
        }

        return false
    }

    mutating func apply(_ move: Move) -> Bool {
        guard isValidMove(move) else {
            return false
        }

        for position in move.occupiedPositions {
            cells[index(for: position)] = .occupied(move.player)
        }

        return true
    }

    private func index(for position: BoardPosition) -> Int {
        position.row * columns + position.column
    }
}

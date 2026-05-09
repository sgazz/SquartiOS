nonisolated struct BoardPosition: Hashable, Codable, Sendable {
    let row: Int
    let column: Int

    init(row: Int, column: Int) {
        self.row = row
        self.column = column
    }

    func offsetBy(rows: Int, columns: Int) -> BoardPosition {
        BoardPosition(row: row + rows, column: column + columns)
    }
}

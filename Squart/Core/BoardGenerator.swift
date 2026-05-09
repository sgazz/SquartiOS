nonisolated enum BoardGenerator {
    static func square(size: Int) -> SquartBoard {
        SquartBoard(rows: size, columns: size)
    }

    static func board(for shape: BoardShape) -> SquartBoard? {
        switch shape {
        case .square(let size):
            return square(size: size)
        default:
            return nil
        }
    }
}

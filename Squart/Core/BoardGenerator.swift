nonisolated enum BoardGenerator {
    static func square(size: Int) -> SquartBoard {
        SquartBoard(rows: size, columns: size)
    }

    static func square(size: Int, inactiveCellRatio: Double) -> SquartBoard {
        board(size: size, playableCells: allCells(size: size), inactiveCellRatio: inactiveCellRatio)
    }

    static func board(for configuration: GameConfiguration) -> SquartBoard {
        guard let board = board(
            for: configuration.boardShape,
            inactiveCellRatio: configuration.inactiveCellRatio,
            seed: configuration.boardSeed
        ) else {
            preconditionFailure("Unsupported board shape.")
        }

        return board
    }

    static func board(for shape: BoardShape) -> SquartBoard? {
        board(for: shape, inactiveCellRatio: 0)
    }

    static func board(for shape: BoardShape, inactiveCellRatio: Double) -> SquartBoard? {
        board(for: shape, inactiveCellRatio: inactiveCellRatio, seed: nil)
    }

    static func board(
        for shape: BoardShape,
        inactiveCellRatio: Double,
        seed: UInt64?
    ) -> SquartBoard? {
        switch shape {
        case .square(let size):
            return board(
                size: size,
                playableCells: allCells(size: size),
                inactiveCellRatio: inactiveCellRatio,
                seed: seed
            )
        case .diamond(let size):
            return board(
                size: size,
                playableCells: diamondCells(size: size),
                inactiveCellRatio: inactiveCellRatio,
                seed: seed
            )
        case .triangle(let size):
            return board(
                size: size,
                playableCells: triangleCells(size: size),
                inactiveCellRatio: inactiveCellRatio,
                seed: seed
            )
        case .circle(let diameter):
            return board(
                size: diameter,
                playableCells: circleCells(size: diameter),
                inactiveCellRatio: inactiveCellRatio,
                seed: seed
            )
        default:
            return nil
        }
    }

    private static func board(
        size: Int,
        playableCells: Set<BoardPosition>,
        inactiveCellRatio: Double,
        seed: UInt64? = nil
    ) -> SquartBoard {
        let safeSize = max(2, size)
        let allCells = allCells(size: safeSize)
        let playableCells = playableCells.intersection(allCells)
        let protectedCells = openingCells(size: safeSize).intersection(playableCells)
        let targetInactiveCount = min(
            Int((Double(playableCells.count) * inactiveCellRatio).rounded()),
            max(0, playableCells.count - protectedCells.count)
        )
        let outsideCells = allCells.subtracting(playableCells)

        guard targetInactiveCount > 0 else {
            return SquartBoard(rows: safeSize, columns: safeSize, outsideCells: outsideCells)
        }

        var candidates = playableCells
            .subtracting(protectedCells)
            .sorted { lhs, rhs in
                if lhs.row == rhs.row {
                    return lhs.column < rhs.column
                }

                return lhs.row < rhs.row
            }

        if let seed {
            var generator = SeededRandomNumberGenerator(seed: seed)
            candidates.shuffle(using: &generator)
        } else {
            candidates.shuffle()
        }

        let inactiveCells = Set(candidates.prefix(targetInactiveCount))

        return SquartBoard(
            rows: safeSize,
            columns: safeSize,
            inactiveCells: inactiveCells,
            outsideCells: outsideCells
        )
    }

    private static func allCells(size: Int) -> Set<BoardPosition> {
        guard size > 0 else {
            return []
        }

        var cells: Set<BoardPosition> = []

        for row in 0..<size {
            for column in 0..<size {
                cells.insert(BoardPosition(row: row, column: column))
            }
        }

        return cells
    }

    private static func diamondCells(size: Int) -> Set<BoardPosition> {
        guard size > 0 else {
            return []
        }

        let center = Double(size - 1) / 2
        let radius = Double(size) / 2
        var cells: Set<BoardPosition> = []

        for row in 0..<size {
            for column in 0..<size {
                let distance = abs(Double(row) - center) + abs(Double(column) - center)

                if distance <= radius {
                    cells.insert(BoardPosition(row: row, column: column))
                }
            }
        }

        return cells
    }

    private static func circleCells(size: Int) -> Set<BoardPosition> {
        guard size > 0 else {
            return []
        }

        let center = Double(size - 1) / 2
        let radius = Double(size) / 2
        var cells: Set<BoardPosition> = []

        for row in 0..<size {
            for column in 0..<size {
                let rowDistance = Double(row) - center
                let columnDistance = Double(column) - center
                let distance = (rowDistance * rowDistance + columnDistance * columnDistance).squareRoot()

                if distance <= radius {
                    cells.insert(BoardPosition(row: row, column: column))
                }
            }
        }

        return cells
    }

    private static func triangleCells(size: Int) -> Set<BoardPosition> {
        guard size > 0 else {
            return []
        }

        var cells: Set<BoardPosition> = []

        for row in 0..<size {
            let width = max(1, Int((Double(row + 1) / Double(size) * Double(size)).rounded()))
            let startColumn = max(0, (size - width) / 2)
            let endColumn = min(size - 1, startColumn + width - 1)

            for column in startColumn...endColumn {
                cells.insert(BoardPosition(row: row, column: column))
            }
        }

        return cells
    }

    private static func openingCells(size: Int) -> Set<BoardPosition> {
        let center = size / 2

        return [
            BoardPosition(row: center, column: center),
            BoardPosition(row: center, column: min(center + 1, size - 1)),
            BoardPosition(row: min(center + 1, size - 1), column: center)
        ]
    }
}

nonisolated private struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        self.state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var value = state
        value = (value ^ (value >> 30)) &* 0xBF58476D1CE4E5B9
        value = (value ^ (value >> 27)) &* 0x94D049BB133111EB
        return value ^ (value >> 31)
    }
}

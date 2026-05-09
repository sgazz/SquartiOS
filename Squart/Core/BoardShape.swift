nonisolated enum BoardShape: Equatable, Sendable {
    case square(size: Int)
    case rectangle(rows: Int, columns: Int)
    case triangle(size: Int)
    case diamond(size: Int)
    case circle(diameter: Int)
    case hexagon(radius: Int)
    case star(points: Int, radius: Int)
    case asymmetric(rows: Int, columns: Int, inactiveCells: Set<BoardPosition>)
    case random(rows: Int, columns: Int)

    var dimensions: (rows: Int, columns: Int) {
        switch self {
        case .square(let size):
            return (size, size)
        case .rectangle(let rows, let columns):
            return (rows, columns)
        case .triangle(let size):
            return (size, size)
        case .diamond(let size):
            return (size, size)
        case .circle(let diameter):
            return (diameter, diameter)
        case .hexagon(let radius):
            let size = radius * 2 + 1
            return (size, size)
        case .star(_, let radius):
            let size = radius * 2 + 1
            return (size, size)
        case .asymmetric(let rows, let columns, _):
            return (rows, columns)
        case .random(let rows, let columns):
            return (rows, columns)
        }
    }
}

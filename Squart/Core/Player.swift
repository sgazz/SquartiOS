nonisolated enum Player: String, CaseIterable, Codable, Sendable {
    case horizontal
    case vertical

    var opponent: Player {
        switch self {
        case .horizontal:
            return .vertical
        case .vertical:
            return .horizontal
        }
    }

    var moveDelta: (rows: Int, columns: Int) {
        switch self {
        case .horizontal:
            return (0, 1)
        case .vertical:
            return (1, 0)
        }
    }
}

nonisolated enum CellState: Equatable, Codable, Sendable {
    case outside
    case inactive
    case empty
    case occupied(Player)

    var isActive: Bool {
        self == .empty || isOccupied
    }

    var isEmpty: Bool {
        self == .empty
    }

    private var isOccupied: Bool {
        if case .occupied = self {
            return true
        }

        return false
    }
}

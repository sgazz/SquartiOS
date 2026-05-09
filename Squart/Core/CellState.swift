nonisolated enum CellState: Equatable, Codable, Sendable {
    case inactive
    case empty
    case occupied(Player)

    var isActive: Bool {
        self != .inactive
    }

    var isEmpty: Bool {
        self == .empty
    }
}

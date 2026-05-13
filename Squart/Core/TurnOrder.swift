nonisolated enum TurnOrder: String, CaseIterable, Identifiable, Codable, Sendable {
    case first = "First"
    case second = "Second"

    var id: Self { self }
}

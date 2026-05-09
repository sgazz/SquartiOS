nonisolated enum GameMode: String, CaseIterable, Identifiable, Sendable {
    case pvp = "Player vs Player"
    case playerVsAI = "Player vs AI"

    var id: Self { self }
}

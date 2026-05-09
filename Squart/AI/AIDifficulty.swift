nonisolated enum AIDifficulty: String, CaseIterable, Identifiable, Sendable {
    case easy = "Easy"
    case medium = "Medium"

    var id: Self { self }
}

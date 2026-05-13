import Foundation

nonisolated struct DailyChallengeCompletion: Codable, Equatable, Identifiable, Sendable {
    let dateKey: String
    let completedAt: Date

    var id: String { dateKey }
}

import Foundation

nonisolated struct DailyChallenge: Equatable, Identifiable, Sendable {
    let dateKey: String
    let seed: UInt64
    let configuration: GameConfiguration
    let descriptor: String

    var id: String { dateKey }

    var title: String {
        "Today's Board"
    }

    var subtitle: String {
        "\(descriptor) · \(dateKey)"
    }
}

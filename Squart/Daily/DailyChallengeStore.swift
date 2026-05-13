import Foundation

@MainActor
final class DailyChallengeStore {
    static let shared = DailyChallengeStore()

    private let generator: DailyChallengeGenerator

    init(generator: DailyChallengeGenerator = DailyChallengeGenerator()) {
        self.generator = generator
    }

    func today() -> DailyChallenge {
        generator.challenge()
    }
}

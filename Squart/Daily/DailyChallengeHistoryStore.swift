import Foundation

nonisolated struct DailyChallengeHistoryStore {
    static let shared = DailyChallengeHistoryStore()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func completions() -> [DailyChallengeCompletion] {
        guard let data = defaults.data(forKey: Key.completions) else {
            return []
        }

        return (try? JSONDecoder().decode([DailyChallengeCompletion].self, from: data)) ?? []
    }

    func completedDateKeys() -> Set<String> {
        Set(completions().map(\.dateKey))
    }

    func isCompleted(dateKey: String) -> Bool {
        completedDateKeys().contains(dateKey)
    }

    @discardableResult
    func markCompleted(dateKey: String, completedAt: Date = Date()) -> Bool {
        var currentCompletions = completions()

        guard !currentCompletions.contains(where: { $0.dateKey == dateKey }) else {
            return false
        }

        currentCompletions.append(
            DailyChallengeCompletion(dateKey: dateKey, completedAt: completedAt)
        )
        currentCompletions.sort { $0.dateKey > $1.dateKey }
        save(currentCompletions)

        return true
    }

    func recentCompletions(limit: Int = 14) -> [DailyChallengeCompletion] {
        Array(completions().prefix(max(0, limit)))
    }

    private func save(_ completions: [DailyChallengeCompletion]) {
        guard let data = try? JSONEncoder().encode(completions) else {
            return
        }

        defaults.set(data, forKey: Key.completions)
    }
}

private extension DailyChallengeHistoryStore {
    nonisolated enum Key {
        static let completions = "squart.dailyChallenge.completions"
    }
}

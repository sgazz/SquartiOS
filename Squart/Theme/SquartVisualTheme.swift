nonisolated enum SquartVisualTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case cappuccino
    case obsidian
    case ivory
    case forest
    case bronzeNight

    static let defaultTheme: SquartVisualTheme = .cappuccino

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .cappuccino:
            return "Cappuccino"
        case .obsidian:
            return "Obsidian"
        case .ivory:
            return "Ivory"
        case .forest:
            return "Forest"
        case .bronzeNight:
            return "Bronze Night"
        }
    }

    var isPremium: Bool {
        switch self {
        case .cappuccino:
            return false
        case .obsidian, .ivory, .forest, .bronzeNight:
            return true
        }
    }

    var shortDescription: String {
        switch self {
        case .cappuccino:
            return "Warm graphite with soft cappuccino accents."
        case .obsidian:
            return "Deep black stone with restrained steel highlights."
        case .ivory:
            return "Calm ivory surfaces with muted bronze detail."
        case .forest:
            return "Dark botanical tones with quiet tactical contrast."
        case .bronzeNight:
            return "Night graphite with richer bronze warmth."
        }
    }
}

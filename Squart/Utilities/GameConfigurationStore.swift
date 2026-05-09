import Foundation

struct GameConfigurationStore {
    static let shared = GameConfigurationStore()

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ configuration: GameConfiguration) {
        defaults.set(modeKey(for: configuration.mode), forKey: Key.mode)
        defaults.set(aiDifficultyKey(for: configuration.aiDifficulty), forKey: Key.aiDifficulty)
        defaults.set(configuration.boardSize, forKey: Key.boardSize)
        defaults.set(configuration.inactiveCellRatio, forKey: Key.inactiveCellRatio)
        defaults.set(shapeKey(for: configuration.boardShape), forKey: Key.boardShape)
    }

    func load() -> GameConfiguration {
        guard
            let modeRaw = defaults.string(forKey: Key.mode),
            let mode = mode(from: modeRaw),
            let aiDifficultyRaw = defaults.string(forKey: Key.aiDifficulty),
            let aiDifficulty = aiDifficulty(from: aiDifficultyRaw),
            let boardSize = defaults.object(forKey: Key.boardSize) as? Int,
            let inactiveCellRatio = defaults.object(forKey: Key.inactiveCellRatio) as? Double,
            let boardShapeRaw = defaults.string(forKey: Key.boardShape),
            let boardShape = boardShape(from: boardShapeRaw, size: boardSize)
        else {
            return .standard
        }

        return GameConfiguration(
            mode: mode,
            aiDifficulty: aiDifficulty,
            boardShape: boardShape,
            boardSize: boardSize,
            inactiveCellRatio: inactiveCellRatio
        )
    }
}

private extension GameConfigurationStore {
    enum Key {
        static let mode = "squart.gameConfiguration.mode"
        static let aiDifficulty = "squart.gameConfiguration.aiDifficulty"
        static let boardSize = "squart.gameConfiguration.boardSize"
        static let inactiveCellRatio = "squart.gameConfiguration.inactiveCellRatio"
        static let boardShape = "squart.gameConfiguration.boardShape"
    }

    func modeKey(for mode: GameMode) -> String {
        switch mode {
        case .pvp:
            return "pvp"
        case .playerVsAI:
            return "playerVsAI"
        }
    }

    func mode(from key: String) -> GameMode? {
        switch key {
        case "pvp":
            return .pvp
        case "playerVsAI":
            return .playerVsAI
        default:
            return nil
        }
    }

    func aiDifficultyKey(for difficulty: AIDifficulty) -> String {
        switch difficulty {
        case .easy:
            return "easy"
        case .medium:
            return "medium"
        case .hard:
            return "hard"
        }
    }

    func aiDifficulty(from key: String) -> AIDifficulty? {
        switch key {
        case "easy":
            return .easy
        case "medium":
            return .medium
        case "hard":
            return .hard
        default:
            return nil
        }
    }

    func shapeKey(for shape: BoardShape) -> String {
        switch shape {
        case .square:
            return "square"
        case .diamond:
            return "diamond"
        case .circle:
            return "circle"
        case .triangle:
            return "triangle"
        default:
            return "square"
        }
    }

    func boardShape(from key: String, size: Int) -> BoardShape? {
        switch key {
        case "square":
            return .square(size: size)
        case "diamond":
            return .diamond(size: size)
        case "circle":
            return .circle(diameter: size)
        case "triangle":
            return .triangle(size: size)
        default:
            return nil
        }
    }
}

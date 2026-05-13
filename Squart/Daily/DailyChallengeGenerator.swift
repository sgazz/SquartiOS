import Foundation

nonisolated struct DailyChallengeGenerator {
    private let calendar: Calendar

    init(calendar: Calendar = .dailyChallengeCalendar) {
        self.calendar = calendar
    }

    func challenge(for date: Date = Date()) -> DailyChallenge {
        let dateKey = Self.dateKey(for: date, calendar: calendar)
        let baseSeed = Self.seed(for: dateKey)

        for attempt in 0..<8 {
            let seed = baseSeed &+ UInt64(attempt)
            let configuration = configuration(seed: seed)
            let board = BoardGenerator.board(for: configuration)

            if board.hasValidMove(for: .horizontal), board.hasValidMove(for: .vertical) {
                return DailyChallenge(
                    dateKey: dateKey,
                    seed: seed,
                    configuration: configuration,
                    descriptor: descriptor(for: configuration)
                )
            }
        }

        let fallback = GameConfiguration(
            mode: .playerVsAI,
            aiDifficulty: .medium,
            humanPlayer: .horizontal,
            humanTurnOrder: .first,
            boardShape: .square(size: 10),
            boardSize: 10,
            inactiveCellRatio: 0.18,
            boardSeed: baseSeed
        )

        return DailyChallenge(
            dateKey: dateKey,
            seed: baseSeed,
            configuration: fallback,
            descriptor: descriptor(for: fallback)
        )
    }

    private func configuration(seed: UInt64) -> GameConfiguration {
        let sizes = [8, 10, 12]
        let ratios = [0.10, 0.18, 0.25]
        let difficulties: [AIDifficulty] = [.easy, .medium, .hard]
        let humanPlayers: [Player] = [.horizontal, .vertical]
        let turnOrders: [TurnOrder] = [.first, .second]

        let size = sizes[index(seed, shift: 8, count: sizes.count)]
        let shape = boardShape(
            index: index(seed, shift: 16, count: 4),
            size: size
        )

        return GameConfiguration(
            mode: .playerVsAI,
            aiDifficulty: difficulties[index(seed, shift: 24, count: difficulties.count)],
            humanPlayer: humanPlayers[index(seed, shift: 40, count: humanPlayers.count)],
            humanTurnOrder: turnOrders[index(seed, shift: 48, count: turnOrders.count)],
            boardShape: shape,
            boardSize: size,
            inactiveCellRatio: ratios[index(seed, shift: 32, count: ratios.count)],
            boardSeed: seed
        )
    }

    private func boardShape(index: Int, size: Int) -> BoardShape {
        switch index {
        case 1:
            return .diamond(size: size)
        case 2:
            return .circle(diameter: size)
        case 3:
            return .triangle(size: size)
        default:
            return .square(size: size)
        }
    }

    private func descriptor(for configuration: GameConfiguration) -> String {
        switch configuration.inactiveCellRatio {
        case ..<0.12:
            return "Open"
        case 0.12..<0.22:
            return "Measured"
        default:
            return "Dense"
        }
    }

    private func index(_ seed: UInt64, shift: UInt64, count: Int) -> Int {
        Int((seed >> shift) % UInt64(count))
    }

    static func dateKey(for date: Date, calendar: Calendar = .dailyChallengeCalendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year ?? 1970
        let month = components.month ?? 1
        let day = components.day ?? 1

        return String(format: "%04d-%02d-%02d", year, month, day)
    }

    static func seed(for dateKey: String) -> UInt64 {
        dateKey.utf8.reduce(0xcbf29ce484222325) { hash, byte in
            (hash ^ UInt64(byte)) &* 0x100000001b3
        }
    }
}

private extension Calendar {
    nonisolated static var dailyChallengeCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .gmt
        return calendar
    }
}

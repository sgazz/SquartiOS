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

    var setupSummary: String {
        let size = "\(configuration.boardSize)x\(configuration.boardSize)"
        let inactive = "\(Int((configuration.inactiveCellRatio * 100).rounded()))%"
        let role = configuration.humanPlayer == .horizontal ? "Horizontal" : "Vertical"
        return "\(shapeName) · \(size) · \(inactive) · \(configuration.aiDifficulty.rawValue) · \(role) · \(configuration.humanTurnOrder.rawValue)"
    }

    var roleSummary: String {
        let role = configuration.humanPlayer == .horizontal ? "Horizontal" : "Vertical"
        return "You: \(role) · \(configuration.humanTurnOrder.rawValue)"
    }

    private var shapeName: String {
        switch configuration.boardShape {
        case .square:
            return "Square"
        case .diamond:
            return "Diamond"
        case .circle:
            return "Circle"
        case .triangle:
            return "Triangle"
        case .rectangle:
            return "Rectangle"
        case .hexagon:
            return "Hexagon"
        case .star:
            return "Star"
        case .asymmetric:
            return "Asymmetric"
        case .random:
            return "Random"
        }
    }
}

import Foundation

enum ScreenshotScene: String, CaseIterable {
    case board2DMidgame
    case board3DCinematic
    case dailyChallenge
    case premiumThemeShowcase
    case diamondBoard
    case circleBoard
    case triangleBoard
    case aiThinking
    case gameOver
    case board12x12

    static func fromLaunchArguments(_ arguments: [String]) -> ScreenshotScene? {
        guard let sceneIndex = arguments.firstIndex(of: "-screenshotScene") else {
            return nil
        }

        let valueIndex = arguments.index(after: sceneIndex)
        guard valueIndex < arguments.count else {
            return nil
        }

        return ScreenshotScene(rawValue: arguments[valueIndex])
    }
}

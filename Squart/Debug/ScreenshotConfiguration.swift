import Foundation

struct ScreenshotConfiguration {
    enum Screen {
        case landing
        case game(GamePreset)
    }

    struct GamePreset {
        let configuration: GameConfiguration
        let boardMode: GameBoardMode
        let appliedPlies: Int
        let dailyChallenge: DailyChallenge?
        let isDailyCompleted: Bool
        let showsAITurnPending: Bool
        let previewOrigin: BoardPosition?
        let aiPreviewPositions: Set<BoardPosition>
        let lockInput: Bool
        let showsGameOverOverlay: Bool
    }

    let scene: ScreenshotScene
    let selectedTheme: SquartVisualTheme
    let screen: Screen
}

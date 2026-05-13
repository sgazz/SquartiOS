import Foundation

enum ScreenshotSceneFactory {
    static func make(_ scene: ScreenshotScene, date: Date = Date()) -> ScreenshotConfiguration {
        switch scene {
        case .board2DMidgame:
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .cappuccino,
                screen: .game(
                    .init(
                        configuration: GameConfiguration(
                            mode: .playerVsAI,
                            aiDifficulty: .medium,
                            humanPlayer: .horizontal,
                            humanTurnOrder: .first,
                            boardShape: .square(size: 10),
                            boardSize: 10,
                            inactiveCellRatio: 0.18,
                            boardSeed: 1_001
                        ),
                        boardMode: .classic,
                        appliedPlies: 11,
                        dailyChallenge: nil,
                        isDailyCompleted: false,
                        showsAITurnPending: false,
                        previewOrigin: nil,
                        aiPreviewPositions: [],
                        lockInput: false,
                        showsGameOverOverlay: false
                    )
                )
            )

        case .board3DCinematic:
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .bronzeNight,
                screen: .game(
                    .init(
                        configuration: GameConfiguration(
                            mode: .playerVsAI,
                            aiDifficulty: .hard,
                            humanPlayer: .horizontal,
                            humanTurnOrder: .first,
                            boardShape: .diamond(size: 10),
                            boardSize: 10,
                            inactiveCellRatio: 0.18,
                            boardSeed: 2_001
                        ),
                        boardMode: .board3D,
                        appliedPlies: 14,
                        dailyChallenge: nil,
                        isDailyCompleted: false,
                        showsAITurnPending: false,
                        previewOrigin: nil,
                        aiPreviewPositions: [],
                        lockInput: false,
                        showsGameOverOverlay: false
                    )
                )
            )

        case .dailyChallenge:
            let challenge = DailyChallengeGenerator().challenge(for: date)
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .forest,
                screen: .game(
                    .init(
                        configuration: challenge.configuration,
                        boardMode: .classic,
                        appliedPlies: 4,
                        dailyChallenge: challenge,
                        isDailyCompleted: false,
                        showsAITurnPending: challenge.configuration.humanTurnOrder == .second,
                        previewOrigin: nil,
                        aiPreviewPositions: [],
                        lockInput: false,
                        showsGameOverOverlay: false
                    )
                )
            )

        case .premiumThemeShowcase:
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .ivory,
                screen: .landing
            )

        case .diamondBoard:
            return makeShapeScene(scene: scene, shape: .diamond(size: 10), seed: 3_001)
        case .circleBoard:
            return makeShapeScene(scene: scene, shape: .circle(diameter: 10), seed: 3_101)
        case .triangleBoard:
            return makeShapeScene(scene: scene, shape: .triangle(size: 10), seed: 3_201)

        case .aiThinking:
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .obsidian,
                screen: .game(
                    .init(
                        configuration: GameConfiguration(
                            mode: .playerVsAI,
                            aiDifficulty: .hard,
                            humanPlayer: .vertical,
                            humanTurnOrder: .second,
                            boardShape: .square(size: 10),
                            boardSize: 10,
                            inactiveCellRatio: 0.18,
                            boardSeed: 4_001
                        ),
                        boardMode: .board3D,
                        appliedPlies: 1,
                        dailyChallenge: nil,
                        isDailyCompleted: false,
                        showsAITurnPending: true,
                        previewOrigin: nil,
                        aiPreviewPositions: [],
                        lockInput: true,
                        showsGameOverOverlay: false
                    )
                )
            )

        case .gameOver:
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .cappuccino,
                screen: .game(
                    .init(
                        configuration: GameConfiguration(
                            mode: .playerVsAI,
                            aiDifficulty: .medium,
                            humanPlayer: .horizontal,
                            humanTurnOrder: .first,
                            boardShape: .square(size: 8),
                            boardSize: 8,
                            inactiveCellRatio: 0.18,
                            boardSeed: 5_001
                        ),
                        boardMode: .board3D,
                        appliedPlies: 120,
                        dailyChallenge: nil,
                        isDailyCompleted: false,
                        showsAITurnPending: false,
                        previewOrigin: nil,
                        aiPreviewPositions: [],
                        lockInput: false,
                        showsGameOverOverlay: true
                    )
                )
            )

        case .board12x12:
            return ScreenshotConfiguration(
                scene: scene,
                selectedTheme: .forest,
                screen: .game(
                    .init(
                        configuration: GameConfiguration(
                            mode: .playerVsAI,
                            aiDifficulty: .medium,
                            humanPlayer: .horizontal,
                            humanTurnOrder: .first,
                            boardShape: .circle(diameter: 12),
                            boardSize: 12,
                            inactiveCellRatio: 0.25,
                            boardSeed: 6_001
                        ),
                        boardMode: .classic,
                        appliedPlies: 18,
                        dailyChallenge: nil,
                        isDailyCompleted: false,
                        showsAITurnPending: false,
                        previewOrigin: nil,
                        aiPreviewPositions: [],
                        lockInput: false,
                        showsGameOverOverlay: false
                    )
                )
            )
        }
    }

    private static func makeShapeScene(scene: ScreenshotScene, shape: BoardShape, seed: UInt64) -> ScreenshotConfiguration {
        ScreenshotConfiguration(
            scene: scene,
            selectedTheme: .cappuccino,
            screen: .game(
                .init(
                    configuration: GameConfiguration(
                        mode: .playerVsAI,
                        aiDifficulty: .medium,
                        humanPlayer: .horizontal,
                        humanTurnOrder: .first,
                        boardShape: shape,
                        boardSize: 10,
                        inactiveCellRatio: 0.18,
                        boardSeed: seed
                    ),
                    boardMode: .classic,
                    appliedPlies: 10,
                    dailyChallenge: nil,
                    isDailyCompleted: false,
                    showsAITurnPending: false,
                    previewOrigin: nil,
                    aiPreviewPositions: [],
                    lockInput: false,
                    showsGameOverOverlay: false
                )
            )
        )
    }
}

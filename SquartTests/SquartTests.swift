import Foundation
import XCTest
@testable import Squart

final class SquartTests: XCTestCase {
    func testHorizontalPlayerCanPlaceValidHorizontalDomino() {
        let board = SquartBoard(rows: 3, columns: 3)
        let move = Move(player: .horizontal, origin: BoardPosition(row: 1, column: 1))

        XCTAssertTrue(board.isValidMove(move))
    }

    func testVerticalPlayerCanPlaceValidVerticalDomino() {
        let board = SquartBoard(rows: 3, columns: 3)
        let move = Move(player: .vertical, origin: BoardPosition(row: 1, column: 1))

        XCTAssertTrue(board.isValidMove(move))
    }

    func testMoveOutsideBoardIsInvalid() {
        let board = SquartBoard(rows: 3, columns: 3)
        let move = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 2))

        XCTAssertFalse(board.isValidMove(move))
    }

    func testMoveOnInactiveCellIsInvalid() {
        let inactiveCell = BoardPosition(row: 0, column: 1)
        let board = SquartBoard(rows: 3, columns: 3, inactiveCells: [inactiveCell])
        let move = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))

        XCTAssertFalse(board.isValidMove(move))
    }

    func testMoveOnOccupiedCellIsInvalid() {
        var board = SquartBoard(rows: 3, columns: 3)
        let firstMove = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))
        let overlappingMove = Move(player: .vertical, origin: BoardPosition(row: 0, column: 1))

        XCTAssertTrue(board.apply(firstMove))
        XCTAssertFalse(board.isValidMove(overlappingMove))
    }

    func testApplyingValidMoveSwitchesCurrentPlayer() {
        var game = SquartGame(board: SquartBoard(rows: 3, columns: 3), startingPlayer: .horizontal)
        let move = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))

        XCTAssertTrue(game.play(move))
        XCTAssertEqual(game.currentPlayer, .vertical)
        XCTAssertNil(game.winner)
    }

    func testGameDetectsNoValidMoves() {
        let game = SquartGame(board: SquartBoard(rows: 1, columns: 1), startingPlayer: .horizontal)

        XCTAssertTrue(game.isFinished)
        XCTAssertTrue(game.validMovesForCurrentPlayer().isEmpty)
    }

    func testWinnerIsPreviousPlayerWhenGameEnds() {
        var game = SquartGame(board: SquartBoard(rows: 2, columns: 2), startingPlayer: .horizontal)
        let winningMove = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))

        XCTAssertTrue(game.play(winningMove))
        XCTAssertTrue(game.isFinished)
        XCTAssertEqual(game.winner, .horizontal)
    }

    func testUndoLastMoveRestoresBoardAndCurrentPlayer() {
        var game = SquartGame(board: SquartBoard(rows: 3, columns: 3), startingPlayer: .horizontal)
        let move = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))

        XCTAssertTrue(game.play(move))
        XCTAssertTrue(game.canUndo)
        XCTAssertEqual(game.cellState(at: BoardPosition(row: 0, column: 0)), .occupied(.horizontal))

        XCTAssertTrue(game.undoLastMove())
        XCTAssertFalse(game.canUndo)
        XCTAssertEqual(game.currentPlayer, .horizontal)
        XCTAssertNil(game.winner)
        XCTAssertEqual(game.cellState(at: BoardPosition(row: 0, column: 0)), .empty)
        XCTAssertEqual(game.cellState(at: BoardPosition(row: 0, column: 1)), .empty)
    }

    func testUndoLastMoveRestoresWinnerState() {
        var game = SquartGame(board: SquartBoard(rows: 2, columns: 2), startingPlayer: .horizontal)
        let winningMove = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))

        XCTAssertTrue(game.play(winningMove))
        XCTAssertEqual(game.winner, .horizontal)

        XCTAssertTrue(game.undoLastMove())
        XCTAssertNil(game.winner)
        XCTAssertEqual(game.currentPlayer, .horizontal)
        XCTAssertFalse(game.isFinished)
    }

    func testUndoLastMoveReturnsFalseWhenHistoryIsEmpty() {
        var game = SquartGame(board: SquartBoard(rows: 3, columns: 3), startingPlayer: .horizontal)

        XCTAssertFalse(game.canUndo)
        XCTAssertFalse(game.undoLastMove())
    }

    func testUndoCanRevertTwoMovePair() {
        var game = SquartGame(board: SquartBoard(rows: 4, columns: 4), startingPlayer: .horizontal)
        let humanMove = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))
        let aiMove = Move(player: .vertical, origin: BoardPosition(row: 1, column: 2))

        XCTAssertTrue(game.play(humanMove))
        XCTAssertTrue(game.play(aiMove))
        XCTAssertEqual(game.currentPlayer, .horizontal)

        XCTAssertTrue(game.undoLastMove())
        XCTAssertEqual(game.currentPlayer, .vertical)
        XCTAssertEqual(game.cellState(at: BoardPosition(row: 1, column: 2)), .empty)

        XCTAssertTrue(game.undoLastMove())
        XCTAssertEqual(game.currentPlayer, .horizontal)
        XCTAssertEqual(game.cellState(at: BoardPosition(row: 0, column: 0)), .empty)
        XCTAssertFalse(game.canUndo)
    }

    func testPlacedMovesTrackAppliedMovesAndUndo() {
        var game = SquartGame(board: SquartBoard(rows: 4, columns: 4), startingPlayer: .horizontal)
        let firstMove = Move(player: .horizontal, origin: BoardPosition(row: 0, column: 0))
        let secondMove = Move(player: .vertical, origin: BoardPosition(row: 0, column: 2))

        XCTAssertTrue(game.play(firstMove))
        XCTAssertTrue(game.play(secondMove))
        XCTAssertEqual(game.placedMoves, [firstMove, secondMove])

        XCTAssertTrue(game.undoLastMove())
        XCTAssertEqual(game.placedMoves, [firstMove])

        XCTAssertTrue(game.undoLastMove())
        XCTAssertTrue(game.placedMoves.isEmpty)
    }

    func testHardAIChoosesLegalImmediateWinningMove() throws {
        let board = SquartBoard(rows: 2, columns: 2)
        let ai = SquartAI()

        let move = try XCTUnwrap(
            ai.move(for: .vertical, opponent: .horizontal, on: board, difficulty: .hard)
        )

        XCTAssertTrue(board.isValidMove(move))

        var simulatedBoard = board
        XCTAssertTrue(simulatedBoard.apply(move))
        XCTAssertFalse(simulatedBoard.hasValidMove(for: .horizontal))
    }

    func testDiamondUsesOutsideCellsAndInternalBlockers() throws {
        let board = try XCTUnwrap(
            BoardGenerator.board(for: .diamond(size: 5), inactiveCellRatio: 0.25)
        )

        XCTAssertEqual(board.cellState(at: BoardPosition(row: 0, column: 0)), .outside)
        XCTAssertEqual(board.cellState(at: BoardPosition(row: 2, column: 2)), .empty)
        XCTAssertFalse(board.isActiveEmptyCell(at: BoardPosition(row: 0, column: 0)))
        XCTAssertGreaterThan(
            (0..<board.rows).flatMap { row in
                (0..<board.columns).map { column in
                    board.cellState(at: BoardPosition(row: row, column: column))
                }
            }
            .filter { $0 == .inactive }
            .count,
            0
        )
    }

    func testCircleUsesOutsideCellsAndStartsPlayable() throws {
        let board = try XCTUnwrap(
            BoardGenerator.board(for: .circle(diameter: 8), inactiveCellRatio: 0.18)
        )

        let states = (0..<board.rows).flatMap { row in
            (0..<board.columns).compactMap { column in
                board.cellState(at: BoardPosition(row: row, column: column))
            }
        }

        XCTAssertTrue(states.contains(.outside))
        XCTAssertTrue(states.contains(.empty))
        XCTAssertTrue(board.hasValidMove(for: .horizontal))
        XCTAssertTrue(board.hasValidMove(for: .vertical))
    }

    func testTriangleUsesOutsideCellsAndStartsPlayable() throws {
        let board = try XCTUnwrap(
            BoardGenerator.board(for: .triangle(size: 10), inactiveCellRatio: 0.18)
        )

        let states = (0..<board.rows).flatMap { row in
            (0..<board.columns).compactMap { column in
                board.cellState(at: BoardPosition(row: row, column: column))
            }
        }

        XCTAssertTrue(states.contains(.outside))
        XCTAssertTrue(states.contains(.empty))
        XCTAssertTrue(board.hasValidMove(for: .horizontal))
        XCTAssertTrue(board.hasValidMove(for: .vertical))
    }

    func testDailyChallengeIsStableForSameDay() {
        let generator = DailyChallengeGenerator()
        let date = fixedDate(year: 2026, month: 5, day: 13)

        let firstChallenge = generator.challenge(for: date)
        let secondChallenge = generator.challenge(for: date)

        XCTAssertEqual(firstChallenge, secondChallenge)
        XCTAssertEqual(firstChallenge.dateKey, "2026-05-13")
        XCTAssertTrue(firstChallenge.configuration.mode == .playerVsAI)
        XCTAssertEqual(firstChallenge.configuration.humanPlayer, secondChallenge.configuration.humanPlayer)
        XCTAssertEqual(firstChallenge.configuration.humanTurnOrder, secondChallenge.configuration.humanTurnOrder)
    }

    func testDailyChallengeChangesAcrossDays() {
        let generator = DailyChallengeGenerator()
        let firstChallenge = generator.challenge(for: fixedDate(year: 2026, month: 5, day: 13))
        let secondChallenge = generator.challenge(for: fixedDate(year: 2026, month: 5, day: 14))

        XCTAssertNotEqual(firstChallenge.seed, secondChallenge.seed)
        XCTAssertNotEqual(firstChallenge.dateKey, secondChallenge.dateKey)
        XCTAssertNotEqual(firstChallenge.configuration, secondChallenge.configuration)
    }

    func testDailyChallengeIncludesRoleAndTurnOrder() {
        let generator = DailyChallengeGenerator()
        let challenge = generator.challenge(for: fixedDate(year: 2026, month: 5, day: 13))

        XCTAssertEqual(challenge.configuration.mode, .playerVsAI)
        XCTAssertTrue(Player.allCases.contains(challenge.configuration.humanPlayer))
        XCTAssertTrue(TurnOrder.allCases.contains(challenge.configuration.humanTurnOrder))
        XCTAssertEqual(challenge.configuration.aiPlayer, challenge.configuration.humanPlayer.opponent)
    }

    func testDailyChallengeHumanSecondStartsWithAIPlayer() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .vertical,
            humanTurnOrder: .second
        )

        XCTAssertEqual(configuration.startingPlayer, configuration.aiPlayer)
    }

    func testDailyChallengeBoardGenerationUsesSeed() {
        let generator = DailyChallengeGenerator()
        let challenge = generator.challenge(for: fixedDate(year: 2026, month: 5, day: 13))

        let firstBoard = BoardGenerator.board(for: challenge.configuration)
        let secondBoard = BoardGenerator.board(for: challenge.configuration)

        XCTAssertEqual(firstBoard, secondBoard)
        XCTAssertTrue(firstBoard.hasValidMove(for: .horizontal))
        XCTAssertTrue(firstBoard.hasValidMove(for: .vertical))
    }

    func testDailyChallengeHistoryPersistsCompletion() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = DailyChallengeHistoryStore(defaults: defaults)

        XCTAssertFalse(store.isCompleted(dateKey: "2026-05-13"))
        XCTAssertTrue(store.markCompleted(dateKey: "2026-05-13", completedAt: fixedDate(year: 2026, month: 5, day: 13)))

        let restoredStore = DailyChallengeHistoryStore(defaults: defaults)
        XCTAssertTrue(restoredStore.isCompleted(dateKey: "2026-05-13"))
        XCTAssertEqual(restoredStore.completedDateKeys(), ["2026-05-13"])
    }

    func testDailyChallengeHistoryPreventsDuplicateCompletions() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = DailyChallengeHistoryStore(defaults: defaults)

        XCTAssertTrue(store.markCompleted(dateKey: "2026-05-13", completedAt: fixedDate(year: 2026, month: 5, day: 13)))
        XCTAssertFalse(store.markCompleted(dateKey: "2026-05-13", completedAt: fixedDate(year: 2026, month: 5, day: 14)))
        XCTAssertEqual(store.completions().count, 1)
    }

    func testGameConfigurationStoreRoundTripsSavedConfiguration() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = GameConfigurationStore(defaults: defaults)
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            aiDifficulty: .hard,
            humanPlayer: .vertical,
            humanTurnOrder: .second,
            boardShape: .triangle(size: 12),
            boardSize: 12,
            inactiveCellRatio: 0.25
        )

        store.save(configuration)

        XCTAssertEqual(store.load(), configuration)
    }

    func testGameConfigurationStoreFallsBackWhenStoredValuesAreInvalid() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        defaults.set("invalid", forKey: "squart.gameConfiguration.mode")
        defaults.set("hard", forKey: "squart.gameConfiguration.aiDifficulty")
        defaults.set(12, forKey: "squart.gameConfiguration.boardSize")
        defaults.set(0.25, forKey: "squart.gameConfiguration.inactiveCellRatio")
        defaults.set("triangle", forKey: "squart.gameConfiguration.boardShape")

        let store = GameConfigurationStore(defaults: defaults)

        XCTAssertEqual(store.load(), .standard)
    }

    func testGameConfigurationStoreFallsBackToDefaultRoleAndTurnOrderWhenInvalid() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        defaults.set("playerVsAI", forKey: "squart.gameConfiguration.mode")
        defaults.set("medium", forKey: "squart.gameConfiguration.aiDifficulty")
        defaults.set("invalidRole", forKey: "squart.gameConfiguration.humanPlayer")
        defaults.set("invalidTurn", forKey: "squart.gameConfiguration.humanTurnOrder")
        defaults.set(10, forKey: "squart.gameConfiguration.boardSize")
        defaults.set(0.18, forKey: "squart.gameConfiguration.inactiveCellRatio")
        defaults.set("square", forKey: "squart.gameConfiguration.boardShape")

        let store = GameConfigurationStore(defaults: defaults)
        let configuration = store.load()

        XCTAssertEqual(configuration.mode, .playerVsAI)
        XCTAssertEqual(configuration.aiDifficulty, .medium)
        XCTAssertEqual(configuration.humanPlayer, .horizontal)
        XCTAssertEqual(configuration.humanTurnOrder, .first)
    }

    func testGameConfigurationDerivesAIPlayerFromHumanHorizontal() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .horizontal,
            humanTurnOrder: .first
        )

        XCTAssertEqual(configuration.aiPlayer, .vertical)
    }

    func testGameConfigurationDerivesAIPlayerFromHumanVertical() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .vertical,
            humanTurnOrder: .first
        )

        XCTAssertEqual(configuration.aiPlayer, .horizontal)
    }

    func testGameConfigurationStartingPlayerHumanHorizontalFirst() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .horizontal,
            humanTurnOrder: .first
        )

        XCTAssertEqual(configuration.startingPlayer, .horizontal)
    }

    func testGameConfigurationStartingPlayerHumanVerticalFirst() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .vertical,
            humanTurnOrder: .first
        )

        XCTAssertEqual(configuration.startingPlayer, .vertical)
    }

    func testGameConfigurationStartingPlayerHumanHorizontalSecond() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .horizontal,
            humanTurnOrder: .second
        )

        XCTAssertEqual(configuration.startingPlayer, .vertical)
    }

    func testGameConfigurationStartingPlayerHumanVerticalSecond() {
        let configuration = GameConfiguration(
            mode: .playerVsAI,
            humanPlayer: .vertical,
            humanTurnOrder: .second
        )

        XCTAssertEqual(configuration.startingPlayer, .horizontal)
    }

    func testAppSettingsStoreDefaultsHapticsOn() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = AppSettingsStore(defaults: defaults)

        XCTAssertTrue(store.load().isHapticsEnabled)
        XCTAssertFalse(store.load().isSoundEffectsEnabled)
    }

    func testAppSettingsStorePersistsFeedbackPreferences() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = AppSettingsStore(defaults: defaults)

        store.save(AppSettings(isHapticsEnabled: false, isSoundEffectsEnabled: true))
        XCTAssertFalse(store.load().isHapticsEnabled)
        XCTAssertTrue(store.load().isSoundEffectsEnabled)

        store.save(AppSettings(isHapticsEnabled: true, isSoundEffectsEnabled: false))
        XCTAssertTrue(store.load().isHapticsEnabled)
        XCTAssertFalse(store.load().isSoundEffectsEnabled)
    }

    func testThemeStoreDefaultsToCappuccino() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = SquartThemeStore(defaults: defaults)

        XCTAssertEqual(store.loadSelectedTheme(), .cappuccino)
    }

    func testThemeStoreRestoresSavedPremiumThemeWhenUnlocked() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = SquartThemeStore(defaults: defaults)
        let access = ThemeAccess(purchasedProductIDs: [StoreProduct.premium.id])

        store.saveSelectedTheme(.forest)

        XCTAssertEqual(store.loadSelectedTheme(access: access), .forest)
    }

    func testThemeStoreFallsBackWhenPremiumThemeIsLocked() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = SquartThemeStore(defaults: defaults)

        store.saveSelectedTheme(.forest)

        XCTAssertEqual(store.loadSelectedTheme(access: .free), .cappuccino)
    }

    func testThemeStoreFallsBackForInvalidStoredTheme() throws {
        let suiteName = "SquartTests.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        defaults.set("invalid-theme", forKey: "squart.theme.selectedThemeID")

        let store = SquartThemeStore(defaults: defaults)

        XCTAssertEqual(store.loadSelectedTheme(), .cappuccino)
    }

    func testThemePremiumFlags() {
        XCTAssertFalse(SquartVisualTheme.cappuccino.isPremium)
        XCTAssertTrue(SquartVisualTheme.obsidian.isPremium)
        XCTAssertTrue(SquartVisualTheme.ivory.isPremium)
        XCTAssertTrue(SquartVisualTheme.forest.isPremium)
        XCTAssertTrue(SquartVisualTheme.bronzeNight.isPremium)
    }

    func testThemeAccessRequiresPremiumForPremiumThemes() {
        XCTAssertTrue(ThemeAccess.free.canUse(.cappuccino))
        XCTAssertFalse(ThemeAccess.free.canUse(.obsidian))

        let premiumAccess = ThemeAccess(purchasedProductIDs: [StoreProduct.premium.id])

        XCTAssertTrue(premiumAccess.canUse(.obsidian))
        XCTAssertTrue(premiumAccess.canUse(.ivory))
        XCTAssertTrue(premiumAccess.canUse(.forest))
        XCTAssertTrue(premiumAccess.canUse(.bronzeNight))
    }

    func testThemeAccessAppliesToPremiumAppIcons() {
        XCTAssertTrue(ThemeAccess.free.canUseAppIcon(for: .cappuccino))
        XCTAssertFalse(ThemeAccess.free.canUseAppIcon(for: .obsidian))

        let premiumAccess = ThemeAccess(purchasedProductIDs: [StoreProduct.premium.id])

        XCTAssertTrue(premiumAccess.canUseAppIcon(for: .obsidian))
        XCTAssertTrue(premiumAccess.canUseAppIcon(for: .ivory))
        XCTAssertTrue(premiumAccess.canUseAppIcon(for: .forest))
        XCTAssertTrue(premiumAccess.canUseAppIcon(for: .bronzeNight))
    }

    func testAppIconNameMappingMatchesThemes() {
        XCTAssertNil(AppIconManager.alternateIconName(for: .cappuccino))
        XCTAssertEqual(AppIconManager.alternateIconName(for: .obsidian), "Obsidian")
        XCTAssertEqual(AppIconManager.alternateIconName(for: .ivory), "Ivory")
        XCTAssertEqual(AppIconManager.alternateIconName(for: .forest), "Forest")
        XCTAssertEqual(AppIconManager.alternateIconName(for: .bronzeNight), "BronzeNight")

        XCTAssertEqual(AppIconManager.theme(forAlternateIconName: nil), .cappuccino)
        XCTAssertEqual(AppIconManager.theme(forAlternateIconName: "Obsidian"), .obsidian)
        XCTAssertEqual(AppIconManager.theme(forAlternateIconName: "Ivory"), .ivory)
        XCTAssertEqual(AppIconManager.theme(forAlternateIconName: "Forest"), .forest)
        XCTAssertEqual(AppIconManager.theme(forAlternateIconName: "BronzeNight"), .bronzeNight)
        XCTAssertNil(AppIconManager.theme(forAlternateIconName: "Unknown"))
    }
}

private extension SquartGame {
    func cellState(at position: BoardPosition) -> CellState? {
        board.cellState(at: position)
    }
}

private func fixedDate(year: Int, month: Int, day: Int) -> Date {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(secondsFromGMT: 0) ?? .current

    return calendar.date(from: DateComponents(year: year, month: month, day: day)) ?? Date(timeIntervalSince1970: 0)
}

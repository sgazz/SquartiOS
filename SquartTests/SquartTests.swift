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
}

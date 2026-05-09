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
}

private extension SquartGame {
    func cellState(at position: BoardPosition) -> CellState? {
        board.cellState(at: position)
    }
}

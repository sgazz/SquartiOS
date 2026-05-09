import SwiftUI

struct BoardDebugView: View {
    let board: SquartBoard
    let currentPlayer: Player
    let isFinished: Bool
    let onTapPosition: (BoardPosition) -> Void

    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            let side = boardSide(for: proxy.size)
            let cellSize = cellSize(for: side)

            VStack(spacing: spacing) {
                ForEach(0..<board.rows, id: \.self) { row in
                    HStack(spacing: spacing) {
                        ForEach(0..<board.columns, id: \.self) { column in
                            let position = BoardPosition(row: row, column: column)
                            CellDebugView(
                                state: board.cellState(at: position) ?? .inactive,
                                isValidOrigin: board.isValidMove(Move(player: currentPlayer, origin: position))
                            ) {
                                onTapPosition(position)
                            }
                            .frame(width: cellSize, height: cellSize)
                            .disabled(!isTappable(position) || isFinished)
                        }
                    }
                }
            }
            .frame(width: gridWidth(cellSize: cellSize), height: gridHeight(cellSize: cellSize))
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func isTappable(_ position: BoardPosition) -> Bool {
        board.isActiveEmptyCell(at: position)
    }

    private func boardSide(for size: CGSize) -> CGFloat {
        max(0, min(size.width, size.height))
    }

    private func cellSize(for boardSide: CGFloat) -> CGFloat {
        let availableWidth = max(0, boardSide - 20)
        let maxDimension = max(board.rows, board.columns)
        let totalSpacing = spacing * CGFloat(maxDimension - 1)
        return max(8, floor((availableWidth - totalSpacing) / CGFloat(maxDimension)))
    }

    private func gridWidth(cellSize: CGFloat) -> CGFloat {
        cellSize * CGFloat(board.columns) + spacing * CGFloat(board.columns - 1)
    }

    private func gridHeight(cellSize: CGFloat) -> CGFloat {
        cellSize * CGFloat(board.rows) + spacing * CGFloat(board.rows - 1)
    }
}

#Preview {
    BoardDebugView(
        board: SquartBoard(
            rows: 10,
            columns: 10,
            inactiveCells: [BoardPosition(row: 1, column: 1)]
        ),
        currentPlayer: .horizontal,
        isFinished: false
    ) { _ in }
    .padding()
    .background(Color.black)
}

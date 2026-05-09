import SwiftUI

struct BoardDebugView: View {
    let board: SquartBoard
    let currentPlayer: Player
    let isFinished: Bool
    let onTapPosition: (BoardPosition) -> Void

    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            let cellSize = cellSize(for: proxy.size)
            let columns = Array(
                repeating: GridItem(.fixed(cellSize), spacing: spacing),
                count: board.columns
            )

            LazyVGrid(columns: columns, spacing: spacing) {
                ForEach(0..<board.rows, id: \.self) { row in
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
            .frame(width: boardWidth(cellSize: cellSize), height: boardWidth(cellSize: cellSize))
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(0.045))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.white.opacity(0.08), lineWidth: 1)
                    )
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(maxWidth: 560)
    }

    private func isTappable(_ position: BoardPosition) -> Bool {
        board.isActiveEmptyCell(at: position)
    }

    private func cellSize(for size: CGSize) -> CGFloat {
        let availableWidth = min(size.width, size.height) - 20
        let totalSpacing = spacing * CGFloat(board.columns - 1)
        return max(18, floor((availableWidth - totalSpacing) / CGFloat(board.columns)))
    }

    private func boardWidth(cellSize: CGFloat) -> CGFloat {
        cellSize * CGFloat(board.columns) + spacing * CGFloat(board.columns - 1)
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

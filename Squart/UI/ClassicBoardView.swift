import SwiftUI

struct ClassicBoardView: View {
    @Environment(\.squartPalette) private var palette

    let board: SquartBoard
    let currentPlayer: Player
    let showMoveHints: Bool
    let isFinished: Bool
    let onTapPosition: (BoardPosition) -> Void

    private let spacing: CGFloat = 4

    var body: some View {
        GeometryReader { proxy in
            let side = boardSide(for: proxy.size)
            let cellSize = cellSize(for: side)
            let gridWidth = gridWidth(cellSize: cellSize)
            let gridHeight = gridHeight(cellSize: cellSize)
            let dominoes = dominoPieces

            ZStack(alignment: .topLeading) {
                VStack(spacing: spacing) {
                    ForEach(0..<board.rows, id: \.self) { row in
                        HStack(spacing: spacing) {
                            ForEach(0..<board.columns, id: \.self) { column in
                                let position = BoardPosition(row: row, column: column)
                                ClassicCellView(
                                    state: board.cellState(at: position) ?? .inactive,
                                    isHintedOrigin: showMoveHints && board.isValidMove(Move(player: currentPlayer, origin: position))
                                ) {
                                    onTapPosition(position)
                                }
                                .frame(width: cellSize, height: cellSize)
                                .disabled(!isTappable(position) || isFinished)
                            }
                        }
                    }
                }
                .frame(width: gridWidth, height: gridHeight)

                ForEach(dominoes) { domino in
                    dominoView(for: domino, cellSize: cellSize)
                        .frame(
                            width: domino.orientation == .horizontal ? (cellSize * 2 + spacing) : cellSize,
                            height: domino.orientation == .vertical ? (cellSize * 2 + spacing) : cellSize
                        )
                        .position(
                            x: center(for: domino, cellSize: cellSize).x,
                            y: center(for: domino, cellSize: cellSize).y
                        )
                        .allowsHitTesting(false)
                }
            }
            .frame(width: gridWidth, height: gridHeight)
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.subtlePanel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(palette.subtleBorder, lineWidth: 1)
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

    private var dominoPieces: [ClassicDominoPiece] {
        var pieces: [ClassicDominoPiece] = []

        for row in 0..<board.rows {
            for column in 0..<board.columns {
                let origin = BoardPosition(row: row, column: column)

                guard case .occupied(let player) = board.cellState(at: origin) else {
                    continue
                }

                switch player {
                case .horizontal:
                    guard column + 1 < board.columns else { continue }
                    let next = BoardPosition(row: row, column: column + 1)
                    guard case .occupied(.horizontal) = board.cellState(at: next) else { continue }
                    pieces.append(ClassicDominoPiece(origin: origin, orientation: .horizontal, owner: player))
                case .vertical:
                    guard row + 1 < board.rows else { continue }
                    let next = BoardPosition(row: row + 1, column: column)
                    guard case .occupied(.vertical) = board.cellState(at: next) else { continue }
                    pieces.append(ClassicDominoPiece(origin: origin, orientation: .vertical, owner: player))
                }
            }
        }

        return pieces
    }

    private func center(for domino: ClassicDominoPiece, cellSize: CGFloat) -> CGPoint {
        let x = CGFloat(domino.origin.column) * (cellSize + spacing)
        let y = CGFloat(domino.origin.row) * (cellSize + spacing)
        let width = domino.orientation == .horizontal ? (cellSize * 2 + spacing) : cellSize
        let height = domino.orientation == .vertical ? (cellSize * 2 + spacing) : cellSize

        return CGPoint(x: x + width / 2, y: y + height / 2)
    }

    private func dominoView(for domino: ClassicDominoPiece, cellSize: CGFloat) -> some View {
        let fill: Color = domino.owner == .horizontal ? palette.secondaryAccent.opacity(0.94) : palette.coolAccent.opacity(0.62)
        let edge: Color = domino.owner == .horizontal ? palette.accent.opacity(0.56) : palette.coolAccent.opacity(0.84)
        let radius = max(4, cellSize * 0.16)

        return RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(fill)
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(edge, lineWidth: 1.2)
            )
    }
}

private struct ClassicDominoPiece: Identifiable {
    let origin: BoardPosition
    let orientation: ClassicDominoOrientation
    let owner: Player

    var id: String {
        "\(origin.row)-\(origin.column)-\(orientation.rawValue)"
    }
}

private enum ClassicDominoOrientation: String {
    case horizontal
    case vertical
}

#Preview {
    ClassicBoardView(
        board: SquartBoard(
            rows: 10,
            columns: 10,
            inactiveCells: [BoardPosition(row: 1, column: 1)]
        ),
        currentPlayer: .horizontal,
        showMoveHints: false,
        isFinished: false
    ) { _ in }
    .padding()
    .background(SquartVisualTheme.defaultTheme.palette.backgroundBottom)
}

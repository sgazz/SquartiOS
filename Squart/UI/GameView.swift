import SwiftUI

struct GameView: View {
    @State private var game = SquartGame(board: BoardGenerator.square(size: 8))

    var body: some View {
        SquartSceneView(board: game.board)
            .ignoresSafeArea()
    }
}

#Preview {
    GameView()
}

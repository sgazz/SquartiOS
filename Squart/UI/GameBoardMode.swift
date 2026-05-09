enum GameBoardMode: String, CaseIterable, Identifiable {
    case debug2D = "Classic"
    case preview3D = "3D Board"

    var id: Self { self }
}

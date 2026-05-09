enum GameBoardMode: String, CaseIterable, Identifiable {
    case debug2D = "2D Debug"
    case preview3D = "3D Preview"

    var id: Self { self }
}

enum GameBoardMode: String, CaseIterable, Identifiable {
    case classic = "2D Board"
    case board3D = "3D Board"

    var id: Self { self }
}

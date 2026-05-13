enum GameBoardMode: String, CaseIterable, Identifiable {
    case classic = "Classic"
    case board3D = "3D Board"

    var id: Self { self }
}

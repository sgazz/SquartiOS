nonisolated enum StoreProduct: String, CaseIterable, Identifiable {
    case premium = "squart.premium"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .premium:
            return "Premium Themes & Icons"
        }
    }
}

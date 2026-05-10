nonisolated enum StoreProduct: String, CaseIterable, Identifiable {
    case supporter = "squart.supporter"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .supporter:
            return "Squart Supporter"
        }
    }
}

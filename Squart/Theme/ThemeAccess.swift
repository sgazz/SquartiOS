nonisolated struct ThemeAccess {
    static let free = ThemeAccess()

    let purchasedProductIDs: Set<String>

    init(purchasedProductIDs: Set<String> = []) {
        self.purchasedProductIDs = purchasedProductIDs
    }

    func canUse(_ theme: SquartVisualTheme) -> Bool {
        !theme.isPremium || purchasedProductIDs.contains(StoreProduct.supporter.id)
    }

    func canUseAppIcon(for theme: SquartVisualTheme) -> Bool {
        canUse(theme)
    }

    func usableTheme(for theme: SquartVisualTheme) -> SquartVisualTheme {
        canUse(theme) ? theme : .defaultTheme
    }
}

nonisolated struct ThemeAccess {
    static let free = ThemeAccess()

    let purchasedProductIDs: Set<String>

    init(purchasedProductIDs: Set<String> = []) {
        self.purchasedProductIDs = purchasedProductIDs
    }

    func canUse(_ theme: SquartVisualTheme) -> Bool {
        let isAllowed = !theme.isPremium || purchasedProductIDs.contains(StoreProduct.supporter.id)
        #if DEBUG
        if theme.isPremium {
            print("[SquartStore] ThemeAccess canUse theme=\(theme.id) allowed=\(isAllowed) supporterOwned=\(purchasedProductIDs.contains(StoreProduct.supporter.id))")
        }
        #endif
        return isAllowed
    }

    func canUseAppIcon(for theme: SquartVisualTheme) -> Bool {
        canUse(theme)
    }

    func usableTheme(for theme: SquartVisualTheme) -> SquartVisualTheme {
        canUse(theme) ? theme : .defaultTheme
    }
}

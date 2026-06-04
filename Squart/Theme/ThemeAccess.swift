nonisolated struct ThemeAccess {
    static let free = ThemeAccess()

    let purchasedProductIDs: Set<String>

    init(purchasedProductIDs: Set<String> = []) {
        self.purchasedProductIDs = purchasedProductIDs
    }

    func canUse(_ theme: SquartVisualTheme) -> Bool {
        #if DEBUG
        // DEBUG ONLY PREMIUM OVERRIDE
        if DebugPremiumUnlock.isEnabled {
            return true
        }
        #endif

        let isAllowed = !theme.isPremium || purchasedProductIDs.contains(StoreProduct.premium.id)
        #if DEBUG
        if theme.isPremium {
            print("[SquartStore] ThemeAccess canUse theme=\(theme.id) allowed=\(isAllowed) premiumOwned=\(purchasedProductIDs.contains(StoreProduct.premium.id))")
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

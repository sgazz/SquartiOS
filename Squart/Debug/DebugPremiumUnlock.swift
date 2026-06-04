#if DEBUG
import Foundation

// DEBUG ONLY PREMIUM OVERRIDE
nonisolated enum DebugPremiumUnlockKey {
    static let userDefaultsKey = "debug.unlockPremium"
}

enum DebugPremiumUnlock {
    nonisolated(unsafe) private static let defaults = UserDefaults.standard

    nonisolated static var isEnabled: Bool {
        defaults.bool(forKey: DebugPremiumUnlockKey.userDefaultsKey)
    }

    static func setEnabled(_ enabled: Bool) {
        defaults.set(enabled, forKey: DebugPremiumUnlockKey.userDefaultsKey)
    }

    /// Merges premium entitlement when the debug override is active. StoreKit IDs are unchanged.
    nonisolated static func effectivePurchasedProductIDs(_ purchasedProductIDs: Set<String>) -> Set<String> {
        guard isEnabled else {
            return purchasedProductIDs
        }

        var ids = purchasedProductIDs
        ids.insert(StoreProduct.premium.id)
        return ids
    }

    nonisolated static func grantsPremiumEntitlement(premiumPurchased: Bool) -> Bool {
        isEnabled || premiumPurchased
    }

    nonisolated static func makeThemeAccess(purchasedProductIDs: Set<String>) -> ThemeAccess {
        ThemeAccess(purchasedProductIDs: effectivePurchasedProductIDs(purchasedProductIDs))
    }
}

#endif

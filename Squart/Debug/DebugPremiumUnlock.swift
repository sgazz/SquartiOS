#if DEBUG
import Foundation

// DEBUG ONLY PREMIUM OVERRIDE
enum DebugPremiumUnlock {
    static let userDefaultsKey = "debug.unlockPremium"

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: userDefaultsKey)
    }

    static func setEnabled(_ enabled: Bool) {
        UserDefaults.standard.set(enabled, forKey: userDefaultsKey)
    }

    /// Merges supporter entitlement when the debug override is active. StoreKit IDs are unchanged.
    static func effectivePurchasedProductIDs(_ purchasedProductIDs: Set<String>) -> Set<String> {
        guard isEnabled else {
            return purchasedProductIDs
        }

        var ids = purchasedProductIDs
        ids.insert(StoreProduct.supporter.id)
        return ids
    }

    static func grantsPremiumEntitlement(supporterPurchased: Bool) -> Bool {
        isEnabled || supporterPurchased
    }

    static func makeThemeAccess(purchasedProductIDs: Set<String>) -> ThemeAccess {
        ThemeAccess(purchasedProductIDs: effectivePurchasedProductIDs(purchasedProductIDs))
    }
}

#endif

#if DEBUG
import SwiftUI

// DEBUG ONLY PREMIUM OVERRIDE
struct DebugPremiumSettingsSection: View {
    @Environment(\.squartPalette) private var palette
    @EnvironmentObject private var storeManager: StoreManager
    @EnvironmentObject private var iconManager: AppIconManager
    @AppStorage(DebugPremiumUnlockKey.userDefaultsKey) private var debugUnlockPremium = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DEBUG PREMIUM")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(palette.mutedText)
                .tracking(0.8)

            Toggle(isOn: $debugUnlockPremium) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Unlock Premium Themes & Icons")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(palette.strongText)

                    Text("Simulates a premium purchase in Debug builds only.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(palette.accent)
            .padding(18)
            .squartCard()
            .animation(SquartTheme.microInteractionAnimation, value: debugUnlockPremium)
        }
        .onChange(of: debugUnlockPremium) { _, isEnabled in
            DebugPremiumUnlock.setEnabled(isEnabled)
            applyEntitlementChange()
        }
    }

    private func applyEntitlementChange() {
        let access = DebugPremiumUnlock.makeThemeAccess(purchasedProductIDs: storeManager.purchasedProductIDs)
        iconManager.refreshSelectedTheme(access: access)
        Task {
            await iconManager.enforceAccessibleIcon(access: access)
        }
        Haptics.selection()
    }
}

#endif

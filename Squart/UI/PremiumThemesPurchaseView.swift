import SwiftUI
import StoreKit

struct PremiumThemesPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.squartPalette) private var palette
    @EnvironmentObject private var storeManager: StoreManager
    #if DEBUG
    @AppStorage(DebugPremiumUnlockKey.userDefaultsKey) private var debugUnlockPremium = false
    #endif

    var body: some View {
        ZStack {
            palette.sheetBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 16) {
                    Text("Unlock all premium themes and alternate app icons with a one-time purchase.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(palette.bodyText)
                        .fixedSize(horizontal: false, vertical: true)

                    priceLine

                    Text("Thank you for supporting Squart.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(palette.mutedText)
                        .fixedSize(horizontal: false, vertical: true)

                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await storeManager.purchaseSupporter()
                            }
                        } label: {
                            Text(purchaseButtonTitle)
                        }
                        .buttonStyle(SquartPrimaryButtonStyle(width: 260))
                        .disabled(storeManager.supporterProduct == nil || hasPremiumEntitlement)

                        Button {
                            Task {
                                await storeManager.restorePurchases()
                            }
                        } label: {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                        }
                        .buttonStyle(SquartSecondaryButtonStyle(width: 260))
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(18)
                .squartCard()

                Spacer(minLength: 0)
            }
            .padding(28)
        }
        .task {
            await storeManager.refreshPurchasedProducts()
            await storeManager.loadProducts()
        }
        .onAppear {
            dismissIfAlreadyUnlocked()
        }
        .onChange(of: storeManager.purchasedProductIDs) { _, _ in
            #if DEBUG
            print("[SquartStore] PremiumThemesPurchaseView observed purchasedProductIDs=\(storeManager.purchasedProductIDs.sorted())")
            #endif
            dismissIfAlreadyUnlocked()
        }
        #if DEBUG
        .onChange(of: debugUnlockPremium) { _, _ in
            dismissIfAlreadyUnlocked()
        }
        #endif
    }

    private var hasPremiumEntitlement: Bool {
        #if DEBUG
        DebugPremiumUnlock.grantsPremiumEntitlement(premiumPurchased: storeManager.isSupporterPurchased)
        #else
        storeManager.isSupporterPurchased
        #endif
    }

    private var header: some View {
        HStack(alignment: .top) {
            Text("Premium Themes & Icons")
                .font(SquartTheme.titleFont(size: 27))
                .foregroundStyle(palette.primaryText)

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(palette.bodyText)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(palette.panel))
            }
            .buttonStyle(SquartTactileButtonStyle(pressedScale: 0.94, pressedOpacity: 0.82))
            .accessibilityLabel("Close premium themes and icons")
        }
    }

    @ViewBuilder
    private var priceLine: some View {
        if let product = storeManager.supporterProduct {
            Text("One-time purchase • \(product.displayPrice)")
                .font(.system(size: 22, weight: .semibold))
                .foregroundStyle(palette.accent)
                .fixedSize(horizontal: false, vertical: true)
        } else if storeManager.isLoading {
            ProgressView()
                .tint(palette.accent)
        }
    }

    private var purchaseButtonTitle: String {
        if hasPremiumEntitlement {
            return "Already Unlocked"
        }

        if let product = storeManager.supporterProduct {
            return "Unlock • \(product.displayPrice)"
        }

        return "Unlock Premium Pack"
    }

    private func dismissIfAlreadyUnlocked() {
        guard hasPremiumEntitlement else {
            return
        }
        dismiss()
    }
}

#Preview {
    PremiumThemesPurchaseView()
        .environmentObject(StoreManager.shared)
}

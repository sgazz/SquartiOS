import SwiftUI
import StoreKit

struct SupportDevelopmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.squartPalette) private var palette
    @StateObject private var storeManager: StoreManager

    @MainActor
    init() {
        self.init(storeManager: .shared)
    }

    @MainActor
    init(storeManager: StoreManager) {
        self._storeManager = StateObject(wrappedValue: storeManager)
    }

    var body: some View {
        ZStack {
            palette.sheetBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    header

                    VStack(alignment: .leading, spacing: 16) {
                        Text("Squart is a native strategy game. Support helps keep it calm, independent, and carefully built.")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(palette.bodyText)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("Squart Supporter unlocks the Premium Theme Pack. Gameplay stays fully available either way.")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(palette.mutedText)
                            .fixedSize(horizontal: false, vertical: true)

                        productState

                        VStack(spacing: 12) {
                            Button {
                                Task {
                                    await storeManager.purchaseSupporter()
                                }
                            } label: {
                                Text(purchaseButtonTitle)
                            }
                            .buttonStyle(SquartPrimaryButtonStyle(width: 260))
                            .disabled(storeManager.supporterProduct == nil || storeManager.isSupporterPurchased)

                            Button {
                                Task {
                                    await storeManager.restorePurchases()
                                }
                            } label: {
                                Text("Restore Purchases")
                            }
                            .buttonStyle(SquartSecondaryButtonStyle(width: 260))
                        }
                        .frame(maxWidth: .infinity)

                        if let statusMessage = storeManager.statusMessage {
                            Text(statusMessage)
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(palette.mutedText)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(18)
                    .squartCard()
                }
                .padding(28)
            }
        }
        .task {
            await storeManager.refreshPurchasedProducts()
            await storeManager.loadProducts()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Support Development")
                    .font(SquartTheme.titleFont(size: 27))
                    .foregroundStyle(palette.primaryText)

                Text("A quiet way to back Squart.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(palette.mutedText)
            }

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
            .accessibilityLabel("Close support screen")
        }
    }

    @ViewBuilder
    private var productState: some View {
        if storeManager.isLoading {
            ProgressView()
                .tint(palette.accent)
        } else if let product = storeManager.supporterProduct {
            VStack(alignment: .leading, spacing: 5) {
                Text(product.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(palette.strongText)

                Text(product.displayPrice)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(palette.accent)
            }
        } else {
            Text("Squart Supporter is not available yet.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(palette.mutedText)
        }
    }

    private var purchaseButtonTitle: String {
        if storeManager.isSupporterPurchased {
            return "Already Supported"
        }

        return storeManager.supporterProduct?.displayName ?? StoreProduct.supporter.displayName
    }
}

#Preview {
    SupportDevelopmentView()
}

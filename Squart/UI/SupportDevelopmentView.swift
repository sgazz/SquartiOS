import SwiftUI
import StoreKit

struct SupportDevelopmentView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeManager = StoreManager()

    var body: some View {
        ZStack {
            SquartTheme.Colors.sheetBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 24) {
                header

                VStack(alignment: .leading, spacing: 16) {
                    Text("Squart is a native strategy prototype. Support helps keep the game calm, independent, and carefully built.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(SquartTheme.Colors.bodyText)
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
                            .foregroundStyle(SquartTheme.Colors.mutedText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
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
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Support Development")
                    .font(SquartTheme.titleFont(size: 27))
                    .foregroundStyle(SquartTheme.Colors.primaryText)

                Text("A quiet way to back Squart.")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(SquartTheme.Colors.mutedText)
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(SquartTheme.Colors.bodyText)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(SquartTheme.Colors.panelGraphite))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close support screen")
        }
    }

    @ViewBuilder
    private var productState: some View {
        if storeManager.isLoading {
            ProgressView()
                .tint(SquartTheme.Colors.cappuccino)
        } else if let product = storeManager.supporterProduct {
            VStack(alignment: .leading, spacing: 5) {
                Text(product.displayName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SquartTheme.Colors.strongText)

                Text(product.displayPrice)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SquartTheme.Colors.cappuccino)
            }
        } else {
            Text("Squart Supporter is not available yet.")
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(SquartTheme.Colors.mutedText)
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

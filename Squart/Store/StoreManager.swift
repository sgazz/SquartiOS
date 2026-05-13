import Combine
import Foundation
import StoreKit

@MainActor
final class StoreManager: ObservableObject {
    static let shared = StoreManager()

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published var statusMessage: String?

    private let productIDs: [String]
    private var transactionUpdatesTask: Task<Void, Never>?

    init(productIDs: [String] = StoreProduct.allCases.map { $0.id }) {
        self.productIDs = productIDs
        self.transactionUpdatesTask = observeTransactionUpdates()
    }

    deinit {
        transactionUpdatesTask?.cancel()
    }

    var supporterProduct: Product? {
        products.first { $0.id == StoreProduct.supporter.id }
    }

    var isSupporterPurchased: Bool {
        purchasedProductIDs.contains(StoreProduct.supporter.id)
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await Product.products(for: productIDs)
                .sorted { $0.displayName < $1.displayName }

            if products.isEmpty {
                statusMessage = "Support options are not available yet."
            } else {
                statusMessage = nil
            }
        } catch {
            products = []
            statusMessage = "Could not load support options."
        }
    }

    func purchaseSupporter() async {
        guard let product = supporterProduct else {
            statusMessage = "Supporter purchase is not available yet."
            return
        }

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                try await handle(verification)
                statusMessage = "Thank you for supporting Squart."
            case .userCancelled:
                statusMessage = nil
            case .pending:
                statusMessage = "Purchase is pending approval."
            @unknown default:
                statusMessage = "Purchase could not be completed."
            }
        } catch {
            statusMessage = "Purchase failed. Please try again later."
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedProducts()
            statusMessage = isSupporterPurchased ? "Purchase restored." : "No supporter purchase was found."
        } catch {
            statusMessage = "Restore failed. Please try again later."
        }
    }

    func refreshPurchasedProducts() async {
        var purchasedIDs: Set<String> = []

        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedIDs.insert(transaction.productID)
            }
        }

        purchasedProductIDs = purchasedIDs
    }

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else {
                    return
                }

                do {
                    try await handle(result)
                } catch {
                    statusMessage = "A purchase update could not be verified."
                }
            }
        }
    }

    private func handle(_ verification: VerificationResult<Transaction>) async throws {
        switch verification {
        case .verified(let transaction):
            purchasedProductIDs.insert(transaction.productID)
            await transaction.finish()
        case .unverified:
            throw StoreError.failedVerification
        }
    }
}

private enum StoreError: Error {
    case failedVerification
}
